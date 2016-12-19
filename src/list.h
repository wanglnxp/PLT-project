#ifndef _LIST_H_
#define _LIST_H_

struct ListNode {
    void *data;
    struct ListNode *next;
};

struct NodeList {
  struct ListNode *head;
};

struct NodeList *init_List();

struct NodeList *add_front(struct NodeList *list, void *data);

struct NodeList *add_back(struct NodeList *list, void *data);

void *index_acess(struct NodeList *list, int id);

int remove_node(struct NodeList *list, int id);

int length(struct NodeList *list);

int isEmptyList(struct NodeList *list);

void *int_to_pointer(int i);

void *float_to_pointer(float f);

int pointer_to_int(void *pi);

float pointer_to_float(void *pf);

int print_bool(char *format);

#endif /* #ifndef _SOURCE_H_ */
