# 01. PostgreSQL
>### 52.2.8. Canceling Requests in Progress
During the processing of a query, the frontend might request cancellation of the query. The cancel request is not sent directly on the open connection to the backend for reasons of implementation efficiency: we don't want to have the backend constantly checking for new input from the frontend during query processing. Cancel requests should be relatively infrequent, so we make them slightly cumbersome in order to avoid a penalty in the normal case.
To issue a cancel request, the frontend opens a new connection to the server and sends a CancelRequest message, rather than the StartupMessage message that would ordinarily be sent across a new connection. The server will process this request and then close the connection. For security reasons, no direct reply is made to the cancel request message.
A CancelRequest message will be ignored unless it contains the same key data (PID and secret key) passed to the frontend during connection start-up. If the request matches the PID and secret key for a currently executing backend, the processing of the current query is aborted. (In the existing implementation, this is done by sending a special signal to the backend process that is processing the query.)
The cancellation signal might or might not have any effect — for example, if it arrives after the backend has finished processing the query, then it will have no effect. If the cancellation is effective, it results in the current command being terminated early with an error message.
The upshot of all this is that for reasons of both security and efficiency, the frontend has no direct way to tell whether a cancel request has succeeded. It must continue to wait for the backend to respond to the query. Issuing a cancel simply improves the odds that the current query will finish soon, and improves the odds that it will fail with an error message instead of succeeding.
Since the cancel request is sent across a new connection to the server and not across the regular frontend/backend communication link, it is possible for the cancel request to be issued by any process, not just the frontend whose query is to be canceled. This might provide additional flexibility when building multiple-process applications. It also introduces a security risk, in that unauthorized persons might try to cancel queries. The security risk is addressed by requiring a dynamically generated secret key to be supplied in cancel requests.
- 打开一个新的连接,发送CancelRequest信息，如果匹配pid和秘钥，会把匹配的后端进程aborted
- https://www.cybertec-postgresql.com/en/cancel-hanging-postgresql-query/
# 02. JAVA
https://www.oracle.com/java/technologies/javase/signals.html#gbzcz
# 03. Solution
[在代码关键步骤上增加`CHECK_FOR_INTERRUPTS();`](<https://www.cybertec-postgresql.com/en/cancel-hanging-postgresql-query/#:~:text=(gdb)%20quit-,Fix%20the%20function%20to%20allow%20the%20user%20to%20cancel%20execution,-To%20improve%20the>)



![[Pasted image 20221209173913.png]]
