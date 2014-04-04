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

Id<br>
PostId<br>
Score (Only present if score > 0)<br>
Text, e.g.: "@Stu Thompson: What a horrible idea, you clueless git!"<br>
CreationDate, e.g.:"2008-09-06T08:07:10.730"<br>
UserDisplayName<br>
UserId (Optional. Absent if user has been deleted?)<br>

---***Badges***

Id<br>
UserId, e.g.: "420"<br>
Name, e.g.: "Teacher"<br>
Date, e.g.: "2008-09-15T08:55:03.923"<br>

---***PostHistory***

Id<br>
PostHistoryTypeId<br>
1.Initial Title - The first title a question is asked with.<br>
2.Initial Body - The first raw body text a post is submitted with.<br>
3.Initial Tags - The first tags a question is asked with.<br>
4.Edit Title - A question's title has been changed.<br>
5.Edit Body - A post's body has been changed, the raw text is stored here as markdown.<br>
6.Edit Tags - A question's tags have been changed.<br>
7.Rollback Title - A question's title has reverted to a previous version.<br>
8.Rollback Body - A post's body has reverted to a previous version - the raw text is stored here.<br>
9.Rollback Tags - A question's tags have reverted to a previous version.<br>
10.Post Closed - A post was voted to be closed.<br>
11.Post Reopened - A post was voted to be reopened.<br>
12.Post Deleted - A post was voted to be removed.<br>
13.Post Undeleted - A post was voted to be restored.<br>
14.Post Locked - A post was locked by a moderator.<br>
15.Post Unlocked - A post was unlocked by a moderator.<br>
16.Community Owned - A post has become community owned.<br>
17.Post Migrated - A post was migrated.<br>
18.Question Merged - A question has had another, deleted question merged into itself.<br>
19.Question Protected - A question was protected by a moderator<br>
20.Question Unprotected - A question was unprotected by a moderator<br>
21.Post Disassociated - An admin removes the OwnerUserId from a post<br>
22.Question Unmerged - A previously merged question has had its answers and votes restored.<br>
PostId<br>
RevisionGUID: At times more than one type of history record can be recorded by a single action. All of these will be grouped using the same RevisionGUID
CreationDate: "2009-03-05T22:28:34.823"<br>
UserId<br>
UserDisplayName: populated if a user has been removed and no longer referenced by user Id<br>
Comment: This field will contain the comment made by the user who edited a post. If PostHistoryTypeId = 10, this field contains the CloseReasonId of the close reason:<br>
1: Exact Duplicate<br>
2: Off-topic<br>
3: Subjective and argumentative<br>
4: Not a real question<br>
7: Too localized<br>
10: General reference<br>
20: Noise or pointless (Meta sites only)<br>
New close reasons:<br>
101: Duplicate<br>
102: Off-topic<br>
103: Unclear what you're asking<br>
104: Too broad<br>
105: Primarily opinion-based<br>
Text: A raw version of the new value for a given revision<br>
1. If PostHistoryTypeId = 10, 11, 12, 13, 14, or 15 this column will contain a JSON encoded string with all users who have voted for the PostHistoryTypeId<br>
2. If it is a duplicate close vote, the JSON string will contain an array of original questions as OriginalQuestionIds<br>
3. If PostHistoryTypeId = 17 this column will contain migration details of either from <url> or to <url><br>

---***PostLinks***

Id <br>
CreationDate when the link was created<br>
PostId id of source post<br>
RelatedPostId id of target/related post<br>
LinkTypeId type of link<br>
1. Linked<br>
2. Duplicate<br>

---***Votes***

Id<br>
PostId<br>
VoteTypeId<br>
1. AcceptedByOriginator<br>
2. UpMod<br>
3. DownMod<br>
4. Offensive<br>
5. Favorite (if VoteTypeId = 5, UserId will be populated)<br>
6. Close<br>
7. Reopen<br>
8. BountyStart (if VoteTypeId = 8, UserId will be populated)<br>
9. BountyClose<br>
10. Deletion<br>
11. Undeletion<br>
12. Spam<br>
15. ModeratorReview  <br>
16. ApproveEditSuggestion<br>
UserId (only present if VoteTypeId is 5 or 8)<br>
CreationDate<br>
BountyAmount (only present if VoteTypeId is 8 or 9)<br>
