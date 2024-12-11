

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
	size_t payload;
};

pennant_node_t *pennant_create(size_t payload)
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
	bag->r = ((size_t)ceil(log2(nel))) + 1;
	bag->S = calloc(bag->r, sizeof(pennant_node_t *));

	return bag;
}

size_t bag_len(bag_t *b)
{
	assert(b);
	size_t len = 0;

	for (size_t k = 0; k < b->r; k++)
	{
		len += pennant_len(b->S[k]);
	}

	return len;
}

void bag_insert(bag_t *b, pennant_node_t *x)
{
	assert(b);
	size_t k = 0;
	while (b->S[k])
	{
		x = pennant_union(b->S[k], x);
		b->S[k] = NULL;
		k++;
	}
	assert(k < b->r);
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
	assert(b);
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
	assert(b);
	for (size_t k = 0; k < b->r; k++)
	{
		pennant_visit(b->S[k], cb, ud);
	}
}

typedef struct bin_repr_s
{
	size_t vertex;
	size_t n;
	size_t *borhood;
	char visited;
	size_t distance;
} bin_repr_t;

typedef struct pbfs_data_s
{
	lua_State *L;
	bag_t *frontier;
	bag_t *next_frontier;
	size_t *D;
	size_t nvertices;
	size_t layer;
	const char *neighborhoodSelector;
	size_t startingVertex;
	bin_repr_t *graph;
	pthread_mutex_t *mutex;
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
	// printf("spawned\n");
	process_layer(arg);

	pthread_exit(arg);

	return arg;
}

void process_layer(pbfs_data_t *data)
{
	if (bag_len(data->frontier) > 128)
	{
		/*
				lua_State *L = data->L;

				pthread_t threadb;

				lua_State *Lb = lua_newthread(L);
				lua_pushvalue(L, 1);
				lua_xmove(L, Lb, 1);
				lua_pop(L, 1);

				pbfs_data_t datab = *data;
				datab.frontier = bag_split(data->frontier);
				datab.L = Lb;

				pthread_create(&threadb, NULL, thread, &datab);

				process_layer(data);

				pthread_join(threadb, NULL);
				// lua_closethread(Lb, L);
				// printf("joined\n");
		*/

		pbfs_data_t datab = *data;
		datab.frontier = bag_split(data->frontier);

		process_layer(&datab);
		process_layer(data);
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

size_t read_size_t(size_t *buffer, FILE *file)
{
	return fread(buffer, sizeof(size_t), 1, file);
}

size_t write_size_t(size_t *buffer, FILE *file)
{
	return fwrite(buffer, sizeof(size_t), 1, file);
}

bin_repr_t *read_graph(const char *filename, size_t *nvertices)
{
	FILE *file = fopen(filename, "rb");

	assert(file != NULL);

	size_t vertex, n, w;

	read_size_t(nvertices, file);

	// printf("The graph has %lu vertices.\n", *nvertices);
	bin_repr_t *repr = calloc(*nvertices, sizeof(bin_repr_t));
	bin_repr_t *each = NULL;

	for (size_t i = 0; i < *nvertices; i++)
	{
		if (i % 1000000 == 0)
		{
			printf(".");
			fflush(stdout);
		}

		read_size_t(&vertex, file);
		each = &repr[vertex];
		each->vertex = vertex;

		read_size_t(&n, file);
		each->n = n;
		each->borhood = calloc(n, sizeof(size_t));

		// printf("The vertex %lu has %lu neighbors.\n", vertex, n);

		for (size_t j = 0; j < n; j++)
		{
			read_size_t(&w, file);
			each->borhood[j] = w;
		}
	}

	fclose(file);

	return repr;
}

int l_load_binary_repr(lua_State *L)
{
	const char *graph_filename = lua_tostring(L, 1);

	size_t nvertices;

	// printf("sizeof(size_t): %lu\n", sizeof(size_t));

	bin_repr_t *graph = read_graph(graph_filename, &nvertices);

	lua_pushinteger(L, nvertices);
	lua_pushlightuserdata(L, graph);

	return 2;
}

void process_layer_bin(pbfs_data_t *data);

void *thread_bin(void *arg)
{
	process_layer_bin(arg);

	return arg;
}

void cb_bin(pennant_node_t *node, void *ud)
{

	pbfs_data_t *data = ud;

	bin_repr_t *vertex = &data->graph[node->payload];
	bin_repr_t *each;

	for (size_t j = 0; j < vertex->n; j++)
	{
		each = &data->graph[vertex->borhood[j]];

		pthread_mutex_lock(data->mutex);

		if (!each->visited)
		{
			each->visited = 1;
			each->distance = data->layer;

			bag_insert(data->next_frontier, pennant_create(each->vertex));
		}

		pthread_mutex_unlock(data->mutex);
	}
}

void process_layer_bin(pbfs_data_t *data)
{
	if (bag_len(data->frontier) > 128)
	{
		pbfs_data_t datab = *data;
		datab.frontier = bag_split(data->frontier);

		pthread_t threadb;

		pthread_create(&threadb, NULL, &thread_bin, &datab);

		process_layer_bin(data);

		pthread_join(threadb, NULL);
	}
	else
	{
		bag_visit(data->frontier, &cb_bin, data);
	}
}

int l_bin_bfs(lua_State *L)
{
	pthread_mutex_t mutex;
	pthread_mutex_init(&mutex, NULL);

	pbfs_data_t data;
	data.mutex = &mutex;
	data.startingVertex = lua_tonumber(L, 1) - 1;
	data.nvertices = lua_tonumber(L, 2);
	data.graph = lua_touserdata(L, 3);
	data.layer = 0;
	data.neighborhoodSelector = NULL;
	data.L = NULL;
	data.D = NULL;
	data.frontier = bag_create(data.nvertices);
	bag_insert(data.frontier, pennant_create(data.startingVertex));

	data.graph[data.startingVertex].visited = 1;

	while (bag_len(data.frontier) > 0)
	{
		data.layer++;
		data.next_frontier = bag_create(data.nvertices);

		process_layer_bin(&data);

		data.frontier = data.next_frontier;
	}

	pthread_mutex_destroy(&mutex);

	lua_newtable(L);

	size_t dist = 0;

	for (size_t k = 0; k < data.nvertices; k++)
	{
		dist = data.graph[k].distance;

		if (dist > 0)
		{
			lua_pushinteger(L, dist);
			lua_seti(L, -2, k + 1);
		}
	}

	return 1;
}

int l_free_binary_repr(lua_State *L)
{
	size_t nvertices = lua_tonumber(L, 1);

	bin_repr_t *graph = lua_touserdata(L, 2);

	for (size_t i = 0; i < nvertices; i++)
	{
		free(graph[i].borhood);
	}

	free(graph);

	return 0;
}

int l_write_graph(lua_State *L)
{
	// at the first position there is the vertices table.
	const char *filename = lua_tostring(L, 2);
	const char *borhood = lua_tostring(L, 3);

	lua_len(L, 1);
	size_t nvertices = lua_tointeger(L, -1);
	lua_pop(L, 1);

	FILE *file = fopen(filename, "wb");

	write_size_t(&nvertices, file);

	size_t buffer;

	for (size_t i = 1; i <= nvertices; i++)
	{
		lua_geti(L, 1, i);

		lua_getfield(L, -1, "index");
		buffer = lua_tointeger(L, -1) - 1;
		lua_pop(L, 1);
		write_size_t(&buffer, file);

		lua_getfield(L, -1, borhood);

		lua_len(L, -1);
		buffer = lua_tointeger(L, -1);
		lua_pop(L, 1);

		write_size_t(&buffer, file);

		/* table is in the stack at index 't' */
		lua_pushnil(L); /* first key */
		while (lua_next(L, -2) != 0)
		{
			/* uses 'key' (at index -2) and 'value' (at index -1) */

			if (lua_type(L, -2) == LUA_TNUMBER)
			{
				lua_getfield(L, -1, "index");
				buffer = lua_tointeger(L, -1) - 1;
				lua_pop(L, 1);
				write_size_t(&buffer, file);
			}

			lua_pop(L, 1);
		}

		lua_pop(L, 2);
	}

	fflush(file);

	fclose(file);

	return 0;
}

const struct luaL_Reg luabag_reg[] = {
	{"pbfs", l_pbfs},
	{"load_binary_repr", l_load_binary_repr},
	{"free_binary_repr", l_free_binary_repr},
	{"bin_bfs", l_bin_bfs},
	{"write_graph", l_write_graph},
	{NULL, NULL} /* sentinel */
};

int luaopen_libluabag(lua_State *L)
{
	luaL_newlib(L, luabag_reg);
	return 1;
}
