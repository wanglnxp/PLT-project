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

#endif /* #ifndef _SOURCE_H_ */
