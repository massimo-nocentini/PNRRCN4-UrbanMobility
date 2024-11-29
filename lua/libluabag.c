

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <lua.h>
#include <lauxlib.h>
#include <time.h>
#include <math.h>
#include <pthread.h>

typedef struct pennant_node_s pennant_node_t;
typedef void (*pennant_callback_t)(pennant_node_t *, void *);

struct pennant_node_s
{
	pennant_node_t *left, *right;
	lua_Integer payload;
};

pennant_node_t *pennant_create(lua_Integer payload)
{
	pennant_node_t *node = calloc(1, sizeof(pennant_node_t));
	node->payload = payload;
	return node;
}

pennant_node_t *pennant_union(pennant_node_t *x, pennant_node_t *y)
{
	y->right = x->left;
	x->left = y;
	return x;
}

pennant_node_t *pennant_split(pennant_node_t *x)
{
	pennant_node_t *y = x->left;
	x->left = y->right;
	y->right = NULL;
	return y;
}

size_t pennant_len(pennant_node_t *x)
{
	return x ? pennant_len(x->left) + pennant_len(x->right) + 1 : 0;
}

void pennant_visit(pennant_node_t *node, pennant_callback_t cb, void *ud)
{
	if (node)
	{
		cb(node, ud);
		pennant_visit(node->left, cb, ud);
		pennant_visit(node->right, cb, ud);
	}
}

void pennant_fa(pennant_node_t *x, pennant_node_t *y, pennant_node_t *z, pennant_node_t **s, pennant_node_t **c)
{
	*s = *c = NULL;

	if (x && !y && !z)
	{
		*s = x;
	}
	else if (!x && y && !z)
	{
		*s = y;
	}
	else if (!x && !y && z)
	{
		*s = z;
	}
	else if (x && y && !z)
	{
		*c = pennant_union(x, y);
	}
	else if (x && !y && z)
	{
		*c = pennant_union(x, z);
	}
	else if (!x && y && z)
	{
		*c = pennant_union(y, z);
	}
	else if (x && y && z)
	{
		*s = x;
		*c = pennant_union(y, z);
	}
}

typedef struct bag_s
{
	pennant_node_t **S;
	size_t r;
	size_t n;
} bag_t;

bag_t *bag_create(size_t nel)
{
	bag_t *bag = malloc(sizeof(bag_t));
	bag->n = nel;
	bag->r = ((size_t)ceil(log2(nel)));
	bag->S = calloc(bag->r, sizeof(pennant_node_t));

	return bag;
}

size_t bag_len(bag_t *b)
{
	size_t len = 0;

	for (size_t k = 0; k < b->r; k++)
	{
		len += pennant_len(b->S[k]);
	}

	return len;
}

void bag_insert(bag_t *b, pennant_node_t *x)
{
	size_t k = 0;
	while (b->S[k])
	{
		x = pennant_union(b->S[k], x);
		b->S[k] = NULL;
		k++;
	}
	b->S[k] = x;
}

bag_t *bag_union(bag_t *S, bag_t *R)
{

	pennant_node_t *y = NULL, *s = NULL, *c = NULL;

	for (size_t k = 0; k <= S->r; k++)
	{
		pennant_fa(S->S[k], R->S[k], y, &s, &c);
		S->S[k] = s;
		y = c;
	}

	return S;
}

bag_t *bag_split(bag_t *b)
{
	bag_t *S = bag_create(b->n);
	pennant_node_t *y = b->S[0];
	b->S[0] = NULL;
	for (size_t k = 1; k < b->r; k++)
	{
		if (!b->S[k])
			continue;

		S->S[k - 1] = pennant_split(b->S[k]);
		b->S[k - 1] = b->S[k];
		b->S[k] = NULL;
	}

	if (y)
		bag_insert(b, y);

	return S;
}

void bag_visit(bag_t *b, pennant_callback_t cb, void *ud)
{
	for (size_t k = 0; k < b->r; k++)
	{
		pennant_visit(b->S[k], cb, ud);
	}
}

typedef struct pbfs_data_s
{
	lua_State *L;
	bag_t *frontier;
	bag_t *next_frontier;
	size_t *D;
	size_t nvertices;
	size_t layer;
	const char *neighborhoodSelector;
	lua_Integer startingVertex;
} pbfs_data_t;

void cb(pennant_node_t *node, void *ud)
{
	lua_Integer index;
	size_t cindex;
	pbfs_data_t *data = ud;
	lua_State *L = data->L;
	size_t *D = data->D;

	lua_getfield(L, 1, "graph");
	lua_getfield(L, -1, "vertices");
	lua_geti(L, -1, node->payload);
	lua_getfield(L, -1, data->neighborhoodSelector);

	lua_pushnil(L); /* first key */
	while (lua_next(L, -2) != 0)
	{
		/* uses 'key' (at index -2) and 'value' (at index -1) */

		lua_getfield(L, -1, "index"); // the vertex to be explored is w at -1 in the stack.
		index = lua_tointeger(L, -1);
		cindex = (size_t)(index - 1);
		lua_pop(L, 1);

		if (data->startingVertex != index && !D[cindex])
		{
			D[cindex] = data->layer;
			bag_insert(data->next_frontier, pennant_create(index));
		}

		lua_pop(L, 1); /* removes 'value'; keeps 'key' for next iteration */
	}

	lua_pop(L, 4);
}

void process_layer(pbfs_data_t *); // prototype

void *thread(void *arg)
{
	//printf("spawned\n");
	process_layer(arg);

	pthread_exit(arg);

	return arg;
}

void process_layer(pbfs_data_t *data)
{
	if (bag_len(data->frontier) > 128)
	{
		pthread_t thread_a, thread_b;

		pbfs_data_t dataa = *data;
		pbfs_data_t datab = *data;

		datab.frontier = bag_split(data->frontier);

		pthread_create(&thread_a, NULL, &thread, &dataa);
		pthread_join(thread_a, NULL);
		//printf("joined\n");
		pthread_create(&thread_b, NULL, &thread, &datab);
		pthread_join(thread_b, NULL);
		//printf("joined\n");
	}
	else
	{
		bag_visit(data->frontier, &cb, data);
	}
}

int l_pbfs(lua_State *L)
{
	// the first argument is a table denoting the vertex from where we want to start.
	const char *neighborhoodSelector = lua_tostring(L, 2);

	pbfs_data_t data;

	lua_getfield(L, 1, "graph");
	lua_getfield(L, -1, "vertices");
	lua_len(L, -1);
	data.nvertices = (size_t)lua_tointeger(L, -1);
	lua_pop(L, 3);

	size_t *D = calloc(data.nvertices, sizeof(size_t));

	lua_getfield(L, 1, "index");
	data.startingVertex = lua_tointeger(L, -1);
	lua_pop(L, 1);

	data.frontier = bag_create(data.nvertices);
	bag_insert(data.frontier, pennant_create(data.startingVertex));

	data.layer = 1;
	data.neighborhoodSelector = neighborhoodSelector;
	data.L = L;
	data.D = D;

	while (bag_len(data.frontier) > 0)
	{
		data.next_frontier = bag_create(data.nvertices);

		process_layer(&data);

		data.frontier = data.next_frontier;
		data.layer++;
	}

	lua_getfield(L, 1, "graph");
	lua_getfield(L, -1, "vertices");

	lua_newtable(L);

	size_t dist;
	lua_Integer i = 0;
	for (size_t k = 0; k < data.nvertices; k++)
	{
		dist = D[k];

		if (dist)
		{
			lua_geti(L, -2, k + 1);
			lua_pushinteger(L, dist);

			lua_settable(L, -3);

			i++;
			lua_geti(L, -2, k + 1);
			lua_seti(L, -2, i);
		}
	}

	return 1;
}

const struct luaL_Reg luabag_reg[] = {
	{"pbfs", l_pbfs},
	{NULL, NULL} /* sentinel */
};

int luaopen_libluabag(lua_State *L)
{
	luaL_newlib(L, luabag_reg);
	return 1;
}
