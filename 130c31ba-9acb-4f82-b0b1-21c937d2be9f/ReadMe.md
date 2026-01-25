
### Why do we need Concurrency Control in Database Projects
This teaches us that Our database can be touch by so many users 
Without failure at same time.
It Answers Several Question: 
1. Who can read
2. Who can Write 
3. Who must wait until an action is performed by previous sessions
4. Who must retry

Data has to be consistent no matter how many session touch it.
For Example:
1. Stock Quantity
2. Seat Counts
3. Order totals
4. Balance


created stock_status_view :

- Helps classify Items - For Easier Restock. If product Quantity is less than 20. I calls it for a re-stock. 