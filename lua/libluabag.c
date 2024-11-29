

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <lua.h>
#include <lauxlib.h>
#include <time.h>
#include <math.h>

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
} bag_t;

bag_t *bag_create(size_t nel)
{
	bag_t *bag = malloc(sizeof(bag_t));
	bag->r = ((int)ceil(log2(nel)));
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
	while (b->S[k] != NULL)
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
	bag_t *f0, *f1;
	lua_Integer *D;
	lua_Integer layer;
	const char *neighborhoodSelector;
} pbfs_data_t;

void cb(pennant_node_t *node, void *ud)
{
	lua_Integer index, cindex;
	pbfs_data_t *data = ud;
	lua_State *L = data->L;
	lua_Integer *D = data->D;

	lua_getfield(L, 1, "graph");
	lua_getfield(L, -1, "vertices");
	lua_geti(L, -1, node->payload);
	lua_getfield(L, 1, data->neighborhoodSelector);

	lua_pushnil(L); /* first key */
	while (lua_next(L, -2) != 0)
	{
		/* uses 'key' (at index -2) and 'value' (at index -1) */

		lua_getfield(L, -1, "index"); // the vertex to be explored is w at -1 in the stack.
		index = lua_tointeger(L, -1);
		cindex = index - 1;
		lua_pop(L, 1);

		if (!D[cindex])
		{
			D[cindex] = data->layer;

			bag_insert(data->f1, pennant_create(index));
		}

		lua_pop(L, 1); /* removes 'value'; keeps 'key' for next iteration */
	}

	lua_pop(L, 4);
}

void process_layer(pbfs_data_t *data)
{
	bag_visit(data->f0, cb, data);
}

int l_pbfs(lua_State *L)
{
	// the first argument is a table denoting the vertex from where we want to start.
	const char *neighborhoodSelector = lua_tostring(L, 2);
	lua_getfield(L, 1, "graph");
	lua_getfield(L, -1, "vertices");
	lua_len(L, -1);
	lua_Integer n = lua_tointeger(L, -1);
	lua_pop(L, 3);

	lua_Integer *D = calloc(n, sizeof(lua_Integer));

	lua_Integer l = 1;

	bag_t *f0, *f1;

	f0 = bag_create(n);
	lua_getfield(L, 1, "index");
	bag_insert(f0, pennant_create(lua_tointeger(L, -1)));
	lua_pop(L, 1);

	pbfs_data_t data;
	data.neighborhoodSelector = neighborhoodSelector;
	data.L = L;
	data.D = D;

	while (bag_len(f0) > 0)
	{
		f1 = bag_create(n);

		data.f0 = f0;
		data.f1 = f1;
		data.layer = l;
		process_layer(&data);

		f0 = f1;
		l++;
	}

	lua_createtable(L, n, 0);

	for (size_t k = 0; k < n; k++)
	{
		lua_pushinteger(L, D[k]);
		lua_seti(L, -2, k + 1);
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