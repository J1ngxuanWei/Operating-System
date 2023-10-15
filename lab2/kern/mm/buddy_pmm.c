#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

// 求以2为底数，n为指数的值
int32_t pow2(int32_t n){
    int32_t result=1;
    for(int i=0;i<n;i++)
    result*=2;
    return result;
};

// 对数向上、向下取整函数
int32_t log2_round_up(int32_t n){
    int32_t temp =n;
    int32_t result=0;
    while(n!=1){
        result++;
        n/=2;
    }
    if(temp%2==1)
    return result+1;
    return result;
};
int32_t log2_round_down(int32_t n){
    int32_t result=0;
    while(n!=1){
        result++;
        n/=2;
    }
    return result;
};


static int64_t *buddy_array;
static int64_t buddy_size;
static struct Page *buddy_base;

#define BUDDY_ROOT              (1)
#define BUDDY_LEFT(a)           ((a)<<1)
#define BUDDY_RIGHT(a)          (((a)<<1)+1)
#define BUDDY_PARENT(a)         ((a)>>1)
#define BUDDY_SIZE(a)           (buddy_size/pow2(log2_round_down(a)))
#define BUDDY_EMPTY(a)          (buddy_array[(a)] == BUDDY_SIZE(a))
#define BUDDY_BLOCK(a,b)        (buddy_size/((b)-(a))+(a)/((b)-(a)))


free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    buddy_base=base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    // 将n向下取整到2的幂
    n=log2_round_down(n);
    buddy_size=n;
    // 把base的地址（物理地址），转到虚拟地址，因为我们会直接写上面的数据，作为这个树还剩下多少个页能分配，如果直接写物理内存会出问题。
    buddy_array = KADDR(page2pa(base));
    memset(buddy_array, 0, n*PGSIZE);
    nr_free += n;
    buddy_array[BUDDY_ROOT]=n;
}

static struct Page * buddy_alloc_pages(size_t n) {
    assert(n > 0);
    struct Page *page;
    int64_t block = BUDDY_ROOT;
    int64_t length = pow2(log2_round_up(n));
    if(n==1)length=1;
    //cprintf("%d\n",length);
    // 查找满足要求的节点
    while (length <= buddy_array[block]) {
        int64_t left = BUDDY_LEFT(block);
        int64_t right = BUDDY_RIGHT(block);
        if (BUDDY_EMPTY(block)) {
            // 分割
            buddy_array[left] = buddy_array[block]>>1;
            buddy_array[right] = buddy_array[block]>>1;
            block = left;
        } else if (length <= buddy_array[left]) { 
            block = left;
        } else if (length <= buddy_array[right]) {
            block = right;
        } else {
            // DEBUG                                    
            assert(0);
        }
    }
    // 分配
    int strr=buddy_size*(block-pow2(log2_round_down(block)))/pow2(log2_round_down(block));
    page = buddy_base;
    for(int i=0;i<strr;i++)
    page++;
    buddy_array[block] = 0;
    nr_free -= length;
    // 更新可用空间信息
    while (block != BUDDY_ROOT) {
        block = BUDDY_PARENT(block);
        buddy_array[block] = buddy_array[BUDDY_LEFT(block)] | buddy_array[BUDDY_RIGHT(block)];
    }
    return page;
}

static void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    int64_t length = log2_round_up(n);
    // 寻找到需要释放的块的索引
    int64_t begin = (base-buddy_base);
    int64_t end = begin + length;
    int64_t block = BUDDY_BLOCK(begin,end);
    // 将空间标记为可用
    for (; p != base + n; p ++) {
        assert(!PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    nr_free += length;
    buddy_array[block] = length;
    // 合并更新
    while (block != BUDDY_ROOT) {
        block = BUDDY_PARENT(block);
        int64_t left = BUDDY_LEFT(block);
        int64_t right = BUDDY_RIGHT(block);
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
            buddy_array[block] = buddy_array[left]<<1;
        } else {
            buddy_array[block] = buddy_array[BUDDY_LEFT(block)] | buddy_array[BUDDY_RIGHT(block)];
        }
    }
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}

static void basic_check(void) {
    assert(BUDDY_ROOT == 1);
    assert(BUDDY_LEFT(3) == 6);
    assert(BUDDY_RIGHT(3) == 7);
    assert(BUDDY_PARENT(6) == 3);
    assert(BUDDY_PARENT(7) == 3);

    int64_t temp=buddy_size;
    buddy_size=16;
    buddy_array[BUDDY_ROOT] = 16;
    assert(BUDDY_SIZE(10) == 2);
    assert(BUDDY_BLOCK(8, 12) == 6);
    assert(BUDDY_EMPTY(BUDDY_ROOT));
    buddy_size=temp;
}

static void alloc_check(void) {
    // 手动建立一个区域来进行测试
    size_t buddy_physical_size_store = buddy_size;
    for (struct Page *p = buddy_base; p < buddy_base + 1026; p++)
        SetPageReserved(p);
    buddy_init();
    buddy_init_memmap(buddy_base, 1026);

    // 测试一下分配页
    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    assert((p3 = alloc_page()) != NULL);

    assert(p0 + 1 == p1);
    assert(p1 + 1 == p2);
    assert(p2 + 1 == p3);

    // 测试一下回收页
    assert(nr_free == buddy_size-4);
    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == buddy_size-1);

    assert((p1 = alloc_page()) != NULL);
    assert((p0 = alloc_pages(2)) != NULL);
    assert(p0 + 2 == p1);

    free_pages(p0, 2);
    free_page(p1);
    free_page(p3);

    struct Page *p;
    assert((p = alloc_pages(3)) == p0);

    // Restore buddy system
    for (struct Page *p = buddy_base; p < buddy_base + buddy_physical_size_store; p++)
        SetPageReserved(p);
    buddy_init();
    buddy_init_memmap(buddy_base, buddy_physical_size_store);
    
}

static void
buddy_check(void) {
    basic_check();
    alloc_check();
}

//这个结构体在
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};