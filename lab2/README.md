# <center>os-lab2 实验报告

## <center>组内人员与源码链接

- 2112495魏靖轩
- 2111822张浩龙
- 2113202刘子瑞

源码仓库：[Github](https://github.com/J1ngxuanWei/Operating-System/tree/main/lab2)

## <center>练习

### 练习1：理解first-fit 连续物理内存分配算法（思考题）

将空闲分区链以地址递增的顺序连接；在进行内存分配时，从链首开始顺序查找，直到找到一块分区的大小可以满足需求时，按照该作业的大小，从该分区中分配出内存，将剩下的空闲分区仍然链在空闲分区链中。

分析和设计实现过程如下：

我们要先熟悉两个数据结构，第一个就是如下所示的每一个物理页的属性结构。

```c
struct Page {
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};
```

该结构四个成员变量意义如下:

- 1、`ref` 表示这样页被页表的引用记数，这里应该就是映射此物理页的虚拟页个数。一旦某页表中有一个页表项设置了虚拟页到这个 `Page` 管理的物理页的映射关系，就会把 `Page` 的 `ref` 加一。反之，若是解除，那就减一。
- 2、 `flags` 表示此物理页的状态标记，有两个标志位，第一个表示是否被保留，如果被保留了则设为 `1`（比如内核代码占用的空间）。第二个表示此页是否是 `free` 的。如果设置为 `1` ，表示这页是 `free` 的，可以被分配；如果设置为 `0` ，表示这页已经被分配出去了，不能被再二次分配。
- 3、`property` 用来记录某连续内存空闲块的大小，这里需要注意的是用到此成员变量的这个 `Page` 一定是连续内存块的开始地址（第一页的地址）。
- 4、`page_link` 是便于把多个连续内存空闲块链接在一起的双向链表指针，连续内存空闲块利用这个页的成员变量 `page_link` 来链接比它地址小和大的其他连续内存空闲块。

然后是下面这个结构。一个双向链表，负责管理所有的连续内存空闲块，便于分配和释放。

```c
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;
```

- free_list 是一个 list_entry 结构的双向链表指针
- nr_free 则记录当前空闲页的个数

先来看看 `default_init` 函数：

```c
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

此函数作用是初始化这个manager，初始化上面提到的这个双向链表指针同时设定空闲页最开始是0个。

然后是 `default_init_memmap`函数：

```c
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```

这个函数中，第一个for循环是用来初始化空闲页链表的，初始化每一个空闲页，确认本页是否为保留页，设置标志位，清空引用。

然后计算空闲页的总数，记录这一个连续块的内存大小，为n。随后更新各项参数。

随后初始化每个物理页面记录，然后将全部的可分配物理页视为一大块空闲块加入空闲链表。

接着是 `default_alloc_memmap`:

主要就是从空闲页块的链表中去遍历，找到第一块大小大于 `n` 的块，然后分配出来，把它从空闲页链表中除去，然后如果有多余的，把分完剩下的部分再次加入会空闲页链表中即可。

首次适配算法要求按照地址从小到大查找空间，所以要求空闲表中的空闲空间按照地址从小到大排序。这样，首次适配算法查询空闲空间的方法就是从链表头部开始找到第一个符合要求的空间，将这个空间从空闲表中删除。空闲空间在分配完要求数量的物理页之后可能会有剩余，那么需要将剩余的部分作为新的空闲空间插入到原空间位置（这样才能保证空闲表中空闲空间地址递增）

```c
static struct Page * default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) { //如果所有的空闲页的加起来的大小都不够，那直接返回NULL
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
        // 此处 le2page 就是将 le 的地址 - page_link 在 Page 的偏移 从而找到 Page 的地址
        struct Page *p = le2page(le, page_link);//将地址转换成页的结构
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
            page = p;
            break;
        }
    }
    if (page != NULL) {
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;//如果选中的第一个连续的块大于n，只取其中的大小为n的块
            SetPageProperty(p);
            // 将多出来的插入到 被分配掉的页块 后面
            list_add(&(page->page_link), &(p->page_link));
        }
        // 最后在空闲页链表中删除掉原来的空闲页
        list_del(&(page->page_link));
        nr_free -= n;//当前空闲页的数目减n
        ClearPageProperty(page);
    }
    return page;
}
```

其主要思路为：

```c
设计思路:
  分配空间的函数中进行了如下修改，因为free_list始终是排序的，分配的page块有剩余空间，那么只需把
	剩余空闲块节点插入到当前节点的前一个节点的后面(或者是当前节点后一个节点的前面)即可
		if (page->property > n) {
	        struct Page *p = page + n;
	        p->property = page->property - n;
	
	        // 将page的property改为n
	        page->property = n;
	
	        // 由于是排好序的链表，只需要在le的前一个节点后面插入即可
	        list_add(list_prev(le), &(p->page_link));
	    }
    
    1.第一种情况(找不到满足需求的可供分配的空闲块(所有的size均 < n))
    2.第二种情况(刚好有满足大小的空闲块)
	    执行分配前
	    --------------          --------------         -------------
	    | size < n   |  <--->   | size = n   |  <--->  | size > n  |
	    --------------          --------------         -------------
	    执行分配后
	    --------------           -------------
	    | size < n   |  <--->    | size > n  |
	    --------------           -------------
    3.第三种情况(不存在刚好满足大小的空闲块，但存在比其大的空闲块)	
    		执行分配前
	    --------------          ------------         --------------
	    | size < n   |  <--->   | size > n |  <--->  | size > n1  |
	    --------------          ------------         --------------
	    执行分配后
	    --------------          ---------------------         --------------
	    | size < n   |  <--->   | size = size - n   |  <--->  | size > n1  |
	    --------------          ---------------------         --------------
```

最后是 `default_free_pages`：

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

首先has将需要释放的空间标记为空，清空标志位，设定其被引用的次数为0。

随后，因为释放了，所以设定这块的空闲块数为n，设定这块是空闲的，把base设为空闲，然后把空闲链表里面表示空闲块数量的变量加n。

随后把这个加到空闲链表free_list上，按照地址从低到高排序加到链表上。

最后，由于空闲表中的记录都是按照物理页地址排序的，所以如果插入位置的前驱或者后继刚好和释放后的空间邻接，那么需要将新的空间与前后邻接的空间合并形成更大的空间。

> 你的first fit算法是否有进一步的改进空间？

有的地方可以添加判别以此来减小时间复杂度，因为链表的操作是非常耗时的。

当一个刚被释放的内存块来说，如果它的邻接空间都是空闲的，那么就不需要进行线性时间复杂度的链表插入操作，而是直接并入邻接空间，时间复杂度为常数。

具体为此部分代码：

```c
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
```

就是在上面的插入部分，可以进行判别，直接把链表作为一个整体插入，这样就是O(1)的复杂度，比上面的要优秀。

### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）

算法将空闲分区链中的空闲分区按照空闲分区由小到大的顺序排序，从而形成空闲分区链。每次从链首进行查找合适的空闲分区为需要分配内存，这样每次找到的空闲分区是和需要大小最接近的，所谓“最佳”。

具体实现编程如下：

`best_fit_init_memmap`函数的设计与first fit一致。

```c
static void
best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));

        /*LAB2 EXERCISE 2: YOUR CODE*/ 
        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
             /*LAB2 EXERCISE 2: YOUR CODE*/ 
            // 编写代码
            // 1、当base < page时，找到第一个大于base的页，将base插入到它前面，并退出循环
            // 2、当list_next(le) == &free_list时，若已经到达链表结尾，将base插入到链表尾部
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```

`best_fit_alloc_pages`函数需要将寻找分配的页的部分进行修改，改为寻找大小最合适的：

```c
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
     /*LAB2 EXERCISE 2: YOUR CODE*/ 
    // 下面的代码是first-fit的部分代码，请修改下面的代码改为best-fit
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量

    // 此部分是寻找最合适的page，仅修改此部分即可
    int str=0;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if(str==0){
            page=p;
            str=1;
            continue;
        }
        if ((p->property - n < page->property - n)&&(p->property >= n)&&(page->property >= n)) {
            page = p;
        }
    }
    
    // 下面是分配的代码，无需修改
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

上面，对于合适的定义为：该页的property与n的差值小于目前的最合适页，同时两个差值均大于等于0，同时全部遍历，删掉break。

最后是`best_fit_free_pages`函数，与first fit一致：

```c
static void
best_fit_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    /*LAB2 EXERCISE 2: YOUR CODE*/ 
    // 编写代码
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        /*LAB2 EXERCISE 2: YOUR CODE*/ 
         // 编写代码
        // 1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        // 4、从链表中删除当前页块
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

> 你的 Best-Fit 算法是否有进一步的改进空间？

上面的分配中，查找page时，可以添加当检索到差值为0时直接退出，可以在某些情况下减小时间复杂度。

### 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）

详情见设计手册-Buddy system.md

## <center>本实验中重要的知识点，以及与对应的OS原理中的知识点

略

## <center>OS原理中很重要，但在实验中没有对应上的知识点

略
