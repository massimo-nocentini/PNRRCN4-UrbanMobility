

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
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
    if (node && cb)
    {
        cb(node, ud);
        pennant_visit(node->left, cb, ud);
        pennant_visit(node->right, cb, ud);
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
    bag_t *frontier;
    bag_t *next_frontier;
    size_t nvertices;
    size_t layer;
    size_t starting_vertex;
    bin_repr_t *vertices;
    pthread_mutex_t *mutex;
} pbfs_data_t;

size_t read_size_t(size_t *buffer, FILE *file)
{
    return fread(buffer, sizeof(size_t), 1, file);
}

bin_repr_t *read_graph(const char *filename, size_t *nvertices)
{
    FILE *file = fopen(filename, "rb");

    assert(file != NULL);

    size_t vertex, n, w;

    read_size_t(nvertices, file);

    bin_repr_t *vertices = calloc(*nvertices, sizeof(bin_repr_t));
    bin_repr_t *each = NULL;

    for (size_t i = 0; i < *nvertices; i++)
    {
        if (i % 1000000 == 0)
        {
            printf(".");
            fflush(stdout);
        }

        read_size_t(&vertex, file);
        each = &vertices[vertex];
        each->vertex = vertex;

        read_size_t(&n, file);
        each->n = n;
        each->borhood = calloc(n, sizeof(size_t));

        for (size_t j = 0; j < n; j++)
        {
            read_size_t(&w, file);
            each->borhood[j] = w;
        }
    }

    fclose(file);

    return vertices;
}

void free_graph(bin_repr_t *vertices, size_t nvertices)
{

    for (size_t i = 0; i < nvertices; i++)
    {
        free(vertices[i].borhood);
    }

    free(vertices);
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

    bin_repr_t *vertex = data->vertices + node->payload;
    bin_repr_t *each;

    for (size_t j = 0; j < vertex->n; j++)
    {
        each = data->vertices + vertex->borhood[j];

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
        // pbfs_data_t dataa = *data;
        pbfs_data_t datab = *data;
        datab.frontier = bag_split(data->frontier);

        // pthread_t threada;
        pthread_t threadb;

        // pthread_create(&threada, NULL, &thread_bin, &dataa);
        pthread_create(&threadb, NULL, &thread_bin, &datab);

        process_layer_bin(data);
        // pthread_join(threada, NULL);
        pthread_join(threadb, NULL);
    }
    else
    {
        bag_visit(data->frontier, &cb_bin, data);
    }
}
void bfs(bin_repr_t *vertices, size_t nvertices, size_t starting_vertex)
{
    pthread_mutex_t mutex;

    pthread_mutex_init(&mutex, NULL);

    pbfs_data_t data;
    data.mutex = &mutex;
    data.starting_vertex = starting_vertex;
    data.nvertices = nvertices;
    data.vertices = vertices;
    data.layer = 0;
    data.frontier = bag_create(data.nvertices);
    bag_insert(data.frontier, pennant_create(starting_vertex));

    data.vertices[starting_vertex].visited = 1;

    while (bag_len(data.frontier) > 0)
    {
        data.layer++;
        data.next_frontier = bag_create(data.nvertices);

        // printf("> %lu\n", data.layer);
        process_layer_bin(&data);

        data.frontier = data.next_frontier;
        // printf("< %lu\n", bag_len(data.frontier));
    }

    pthread_mutex_destroy(&mutex);

    // printf("Finished.\n");
}

int main(int argc, const char **argv)
{
    const char *graph_filename = argv[1];

    size_t nvertices;

    bin_repr_t *vertices = read_graph(graph_filename, &nvertices);

    bfs(vertices, nvertices, 10);

    free_graph(vertices, nvertices);

    return 0;
}