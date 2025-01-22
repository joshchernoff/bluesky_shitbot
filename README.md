![](https://shitbot.morphic.pro/images/bot.webp?vsn=d)
# BlueSky🦋 Shit💩 Bot🤖

I wanted to join BlueSky but found that a large portion of users that are following me are not real and dishonest.

A common trait is they are following disproportionately to that of people following them back. On average I noticed that a Following to Followers ratio of 1% i.e. 100:1 is a common factor. 

Sadly bluesky has a concept of starter packs where new users can mass follow many people all at once. Some of these starter packs have users that you can mass follow in the 200+ range. These users commonly get flagged as false positives because they are typically new users who are just following a bunch of people. 

At the moment I only check the ratio given a user is following more than 200+ accounts. 
Though this may change in the future. 

The other metric I look at is the following to post count of 0.1% or 1000:1
Given a user is following more than 1k+ accounts but only has 1 post this too is a common flag for bots. In very rare cases I’ve seen false positives in this case. 
The issue with flagging bots after they follow 1k+ users is that it’s already likely to be picked up by the moderation and have already spammed 1k+ people. Some of which are already following the bot back. 


Roadmap:
- [x] Automate adding to list if criteria met 
- [x] Search users handles and DID from webpage
- [x] Ignore users who have been removed from list from future criteria checks
- [x] Add user via chat message
- [x] Remove user via chat message
- [x] find user via chat message
- [ ] Allow users to submit appeals that will automatically re-evaluate their account and remove it if they fall outside the flag.  IE new users who finally get some followers.   
- [ ] Allow users to submit accounts for addition that are not currently in the db.    
- [ ] Better notification of removal from list.   
