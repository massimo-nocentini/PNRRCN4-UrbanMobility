

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <lua.h>
#include <lauxlib.h>
#include <time.h>

typedef struct pennant_node_s *pennant_node_t;

struct pennant_node_s
{
	pennant_node_t left, right;
	void *payload;
};

pennant_node_t pennant_create(void *payload)
{
	pennant_node_t node = calloc(1, sizeof(struct pennant_node_s));
	node->payload = payload;
	return node;
}

pennant_node_t pennant_union(pennant_node_t x, pennant_node_t y)
{
	y->right = x->left;
	x->left = y;
	return x;
}

pennant_node_t pennant_split(pennant_node_t x)
{
	pennant_node_t y = x->left;
	x->left = y->right;
	y->right = NULL;
	return y;
}

typedef struct bag_s *bag_t;

struct bag_s
{
	pennant_node_t *S;
	size_t r;
};

bag_t bag_create(size_t r)
{
	bag_t bag = malloc(sizeof(struct bag_s));
	bag->r = r;
	bag->S = calloc(r + 1, sizeof(struct pennant_node_s));

	return bag;
}

void bag_insert(bag_t B, void *payload)
{
	pennant_node_t x = pennant_create(payload);
	size_t k = 0UL;
	while (B->S[k] != NULL)
	{
		x = pennant_union(B->S[k], x);
		B->S[k] = NULL;
		k++;
	}
	B->S[k] = x;
}

int l_mktree(lua_State *L)
{

	return 0;
}

const struct luaL_Reg luabag_reg[] = {
	{"mktree", l_mktree},
	{NULL, NULL} /* sentinel */
};

int luaopen_libluabag(lua_State *L)
{
	luaL_newlib(L, luabag_reg);
	return 1;
}