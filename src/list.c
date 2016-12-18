#include <stdio.h>
#include <stdlib.h>
#include "list.h"

struct NodeList* init_List()
{
  struct NodeList* new = (struct NodeList*) malloc(sizeof(struct NodeList));
  new->head = NULL;
  return new;
}

struct NodeList *add_front(struct NodeList *list, void *data)
{
  struct ListNode *node = (struct ListNode*) malloc(sizeof(struct ListNode));

  /* judge */
  if (node == NULL){
    perror("malloc returned a NULL");
    exit(1);
  }

  node->data = data;
  node->next = list->head;
  list->head = node;
  return list;
}

struct NodeList *add_back(struct NodeList *list, void *data)
{
  struct ListNode* new;
  if (list->head == NULL){
    list->head = (struct ListNode*) malloc(sizeof(struct ListNode));
    new = list->head;
  }
  else{
    struct ListNode* node = list->head;
    while (node->next != NULL)
      node = node->next;
    node->next = (struct ListNode*) malloc(sizeof(struct ListNode));
    new = node->next;
  }

  new->data = data;
  new->next = NULL;
  return list;
}

void *index_acess(struct NodeList *list, int id)
{
  /*printf("%d\n", id);
  if(list->head)
     printf("%d\n", length(list));*/
  if (id >= length(list)){
    perror("id is longer than list length");
    exit(1);
  }
  struct ListNode* node = list->head;
  while (id > 0){
    node = node->next;
    id--;
  }

  // printf("%d\n", pointer_to_int(node->data));
  return node->data;
}

int remove_node(struct NodeList *list, int id)
{
  if (id >= length(list))
    return -1;

  struct ListNode *dummy = (struct ListNode*) malloc(sizeof(struct ListNode));
  dummy->data = NULL;
  dummy->next = list->head;

  struct ListNode *tmp_pre = dummy;
  struct ListNode *tmp = dummy->next;

  while(id > 0)
  {
    tmp_pre = tmp_pre->next;
    tmp = tmp->next;
  }

  tmp_pre->next = tmp->next;
  free(tmp);

  list->head = dummy->next;
  free(dummy);

  return 0;
}

int length(struct NodeList *list)
{
  if (!list) {
    return -1;
  }
  int l = 0;
  struct ListNode* tmp = list->head;
  
  while(tmp)
  {
    l++;
    tmp = tmp -> next;
  } 
  
  return l;
}

int isEmptyList(struct NodeList *list)
{
  return (list->head == NULL);
}


void *int_to_pointer(int i)
{
   int *pi = (int *)malloc(sizeof(int));
   *pi = i;
   return (void*)pi;
}

void *float_to_pointer(float f)
{
   float *pf = (float *)malloc(sizeof(float));
   *pf = f;
   return (void*)pf;
}

int pointer_to_int(void *pi)
{
   return *((int*)pi);
}

float pointer_to_float(void *pf)
{
   return *((float*)pf);
}
