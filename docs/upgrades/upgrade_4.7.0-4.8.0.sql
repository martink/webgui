insert into webguiVersion values ('4.8.0','upgrade',unix_timestamp());
update incrementer set nextValue=100000 where incrementerId='messageId';
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (748,1,'WebGUI','User Count', 1036553016);
INSERT INTO template VALUES (5,'Classifieds','<tmpl_var searchForm>\r\n\r\n<tmpl_if post>\r\n    <tmpl_var post> �\r\n</tmpl_if>\r\n<tmpl_var search><p/>\r\n\r\n<table width=\"100%\" cellpadding=3 cellspacing=0 border=0>\r\n<tr>\r\n<tmpl_loop submissions_loop>\r\n\r\n<td valign=\"top\" class=\"tableData\" width=\"33%\" style=\"border: 1px dotted black; padding: 10px;\">\r\n  <h2><a href=\"<tmpl_var submission.url>\"><tmpl_var submission.title></a></h2>\r\n  <tmpl_if submission.currentUser>\r\n    (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n<br/>\r\n  <tmpl_if submission.thumbnail>\r\n       <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"/ align=\"right\"></a><br/>\r\n  </tmpl_if>\r\n<tmpl_var submission.content>\r\n</td>\r\n\r\n<tmpl_if submission.thirdColumn>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var previousPage>  � <tmpl_var pageList> � <tmpl_var nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS');
INSERT INTO template VALUES (6,'Guest Book','<tmpl_if post>\r\n    <tmpl_var post><p>\r\n</tmpl_if>\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tmpl_if __odd__>\r\n<div class=\"highlight\">\r\n</tmpl_if>\r\n\r\n<b>On <tmpl_var submission.date> <a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a> from <a href=\"<tmpl_var submission.url>\">the <tmpl_var submission.title> department</a> wrote</b>, <i><tmpl_var submission.content></i>\r\n\r\n<tmpl_if __odd__>\r\n</div >\r\n</tmpl_if>\r\n\r\n<p/>\r\n\r\n</tmpl_loop>\r\n\r\n<tmpl_if multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var previousPage> � <tmpl_var nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS');
delete from international where namespace='Article' and internationalId=14;
delete from international where namespace='Article' and internationalId=15;
delete from international where namespace='Article' and internationalId=16;
delete from international where namespace='Article' and internationalId=17;
alter table Article add column templateId int not null default 1;
update Article set templateId=2 where alignImage='center';
update Article set templateId=3 where alignImage='left';
alter table Article drop column alignImage;
INSERT INTO template VALUES (1,'Default Article','<tmpl_if image>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image>\" align=\"right\" border=\"0\">\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if link.url>\r\n  <tmpl_if link.title>\r\n    <p><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box>\r\n\r\n<tmpl_if image>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n','Article');
INSERT INTO template VALUES (2,'Center Image','<tmpl_if image>\r\n  <div align=\"center\"><img src=\"<tmpl_var image>\" border=\"0\"></div>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if link.url>\r\n  <tmpl_if link.title>\r\n    <p><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box>\r\n\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n','Article');
INSERT INTO template VALUES (3,'Left Align Image','<tmpl_if image>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image>\" align=\"left\" border=\"0\">\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if link.url>\r\n  <tmpl_if link.title>\r\n    <p><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box>\r\n\r\n<tmpl_if image>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n','Article');
create table userSessionScratch (sessionId varchar(60), name varchar(35), value varchar(255));
create table pageStatistics (
dateStamp int,
userId int,
username varchar(35),
ipAddress varchar(15),
userAgent varchar(255),
referer text,
pageId int,
pageTitle varchar(255)
);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (749,1,'WebGUI','Track page statistics?', 1036736182);
insert into settings values ("trackPageStatistics",0);
alter table pageStatistics add column wobjectId int;
alter table pageStatistics add column function varchar(60);
alter table images rename collateral;
alter table imageGroup rename collateralFolder;
alter table collateral change imageId collateralId int not null;
alter table collateral change imageGroupId collateralFolderId int not null;
alter table collateralFolder change imageGroupId collateralFolderId int not null;
alter table collateral add column collateralType varchar(30) not null default 'image';
update incrementer set incrementerId='collateralId' where incrementerId='imageId';
update incrementer set incrementerId='collateralFolderId' where incrementerId='imageGroupId';
insert into help (helpId,namespace,titleId,bodyId,seeAlso) values (49, 'WebGUI', 785, 786, NULL);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=394;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (394,1,'WebGUI','Manage collateral.', 1036954925);
delete from international where namespace='WebGUI' and internationalId=393;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (785,1,'WebGUI','Collateral, Manage', 1036954767);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (786,1,'WebGUI','', 1036954767);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (784,1,'WebGUI','Thumbnail', 1036954393);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (783,1,'WebGUI','Type', 1036954378);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (782,1,'WebGUI','Any', 1036913053);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (781,1,'WebGUI','Snippet', 1036912954);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (780,1,'WebGUI','File', 1036912946);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (779,1,'WebGUI','Image', 1036912938);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (778,1,'WebGUI','Folder Description', 1036906132);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (777,1,'WebGUI','Folder Id', 1036905972);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (776,1,'WebGUI','Edit Folder', 1036905944);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (775,1,'WebGUI','Are you certain you wish to delete this folder and move its contents to it\'s parent folder?', 1036903002);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (774,1,'WebGUI','Are you certain you wish to delete this collateral? It cannot be recovered once deleted.', 1036902945);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (773,1,'WebGUI','File', 1036893165);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (772,1,'WebGUI','Edit File', 1036893140);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (771,1,'WebGUI','Snippet', 1036893079);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (770,1,'WebGUI','Edit Snippet', 1036893050);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (769,1,'WebGUI','Organize in Folder', 1036893015);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (768,1,'WebGUI','Name', 1036892946);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (767,1,'WebGUI','Collateral Id', 1036892929);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (766,1,'WebGUI','Back to collateral list.', 1036892898);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (765,1,'WebGUI','Delete this collateral item.', 1036892866);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (764,1,'WebGUI','Edit this collateral item.', 1036892856);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (763,1,'WebGUI','Add a snippet.', 1036892785);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (762,1,'WebGUI','Add a file.', 1036892774);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (761,1,'WebGUI','Add an image.', 1036892765);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (760,1,'WebGUI','Delete this folder.', 1036892740);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (759,1,'WebGUI','Edit this folder.', 1036892731);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (758,1,'WebGUI','Add a folder.', 1036892705);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (757,1,'WebGUI','Manage Collateral', 1036892669);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (756,1,'WebGUI','Back to group list.', 1036867726);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (754,1,'WebGUI','Manage the users in this group.', 1036866994);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (753,1,'WebGUI','Edit this group.', 1036866979);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (752,1,'WebGUI','View this user\'s profile.', 1036864965);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (751,1,'WebGUI','Become this user.', 1036864905);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (750,1,'WebGUI','Delete this user.', 1036864742);
delete from international where namespace='WebGUI' and internationalId=393;
delete from international where namespace='WebGUI' and internationalId=396;
delete from international where namespace='WebGUI' and internationalId=397;
delete from international where namespace='WebGUI' and internationalId=389;
delete from international where namespace='WebGUI' and internationalId=383;
delete from international where namespace='WebGUI' and internationalId=544;
delete from international where namespace='WebGUI' and internationalId=545;
delete from international where namespace='WebGUI' and internationalId=546;
delete from international where namespace='WebGUI' and internationalId=547;
delete from international where namespace='WebGUI' and internationalId=548;
delete from international where namespace='WebGUI' and internationalId=549;
delete from international where namespace='WebGUI' and internationalId=550;
delete from international where namespace='WebGUI' and internationalId=392;
delete from international where namespace='WebGUI' and internationalId=382;
delete from international where namespace='WebGUI' and internationalId=390;
delete from international where namespace='WebGUI' and internationalId=673;
delete from international where namespace='WebGUI' and internationalId=628;
delete from international where namespace='WebGUI' and internationalId=686;
delete from international where namespace='WebGUI' and internationalId=641;
delete from international where namespace='WebGUI' and internationalId=676;
delete from international where namespace='WebGUI' and internationalId=631;
delete from help where namespace='WebGUI' and helpId=26;
delete from help where namespace='WebGUI' and helpId=23;
delete from help where namespace='WebGUI' and helpId=36;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (790,1,'WebGUI','Delete this profile category.', 1036964807);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (789,1,'WebGUI','Edit this profile category.', 1036964795);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (788,1,'WebGUI','Delete this profile field.', 1036964681);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (787,1,'WebGUI','Edit this profile field.', 1036964659);
delete from settings where name='imageManagersGroup';
delete from international where languageId=1 and namespace='WebGUI' and internationalId=586;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (586,1,'WebGUI','Manage Translations', 1036971445);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=589;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (589,1,'WebGUI','Edit Translation', 1036971172);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=598;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (598,1,'WebGUI','Edit this translation.', 1036971142);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=584;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (584,1,'WebGUI','Add a new translation.', 1036971092);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=718;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (718,1,'WebGUI','Export this translation.', 1036970877);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=593;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (593,1,'WebGUI','Submit this translation.', 1036970850);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=791;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (791,1,'WebGUI','Delete this translation.', 1036970806);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (802,1,'WebGUI','WebGUI is not currently tracking page statistics. You can enable this feature in the settings.', 1036979395);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (801,1,'WebGUI','Wobject Interactions', 1036978843);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (800,1,'WebGUI','Unique Visitors', 1036978829);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (799,1,'WebGUI','Page Views', 1036978804);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (798,1,'WebGUI','Page Title', 1036978688);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (797,1,'WebGUI','View traffic statistics.', 1036978191);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (796,1,'WebGUI','View page statistics.', 1036978043);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (795,1,'WebGUI','Roots', 1036972103);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (794,1,'WebGUI','Packages', 1036971944);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (793,1,'WebGUI','Pieces of Collateral', 1036971785);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (792,1,'WebGUI','Templates', 1036971696);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (805,1,'WebGUI','Delete this style.', 1037075787);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (804,1,'WebGUI','Copy this style.', 1037075775);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (803,1,'WebGUI','Edit this style.', 1037075751);






