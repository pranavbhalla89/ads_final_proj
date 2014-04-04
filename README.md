Recommendation System for StackExchange
==============
## Schema

---***Posts***

Id<br>
PostTypeId<br>
1. Question<br>
2. Answer<br>
3. Orphaned tag wiki<br>
4. Tag wiki excerpt<br>
5. Tag wiki<br>
6. Moderator nomination<br>
7. "Wiki placeholder" (seems to only be the election description)<br>
8. Privilege wiki<br>
AcceptedAnswerId (only present if PostTypeId is 1)<br>
ParentID (only present if PostTypeId is 2)<br>
CreationDate<br>
Score<br>
ViewCount<br>
Body<br>
OwnerUserId (present only if user has not been deleted; always -1 for tag wiki entries (i.e., the community user owns them))<br>
OwnerDisplayName<br>
LastEditorUserId<br>
LastEditorDisplayName="Rich B"<br>
LastEditDate="2009-03-05T22:28:34.823" - the date and time of the most recent edit to the post<br>
LastActivityDate="2009-03-11T12:51:01.480" - the date and time of the most recent activity on the post. For a question, this could be the post being edited, a new answer was posted, a bounty was started, etc.<br>
Title<br>
Tags<br>
AnswerCount<br>
CommentCount<br>
FavoriteCount<br>
ClosedDate (present only if the post is closed)<br>
CommunityOwnedDate (present only if post is community wikied)<br>

---***Users***

Id<br>
Reputation<br>
CreationDate<br>
DisplayName<br>
LastAccessDate<br>
WebsiteUrl<br>
Location<br>
AboutMe<br>
Views<br>
UpVotes<br>
DownVotes<br>
ProfileImageUrl<br>
AccountId<br>
Age<br>

---***Comments***

Id
PostId
Score (Only present if score > 0)
Text, e.g.: "@Stu Thompson: What a horrible idea, you clueless git!"
CreationDate, e.g.:"2008-09-06T08:07:10.730"
UserDisplayName
UserId (Optional. Absent if user has been deleted?)

