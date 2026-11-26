create table powerplay_ball as (select bowler,count(wicket_type) as 'Wickets' from ipl
where ball between 0.1 and 5.6 and wicket_type in("bowled","caught","stumped","lbw")
group by bowler);

alter table powerplay_ball
add column overs_bowled int;

update powerplay_ball s join (select bowler,count(ball) as overs_bowled from ipl
where ball between 0.1 and 5.6 and ball like "%.1" and wide=0 and noballs=0
group by bowler) b
on s.bowler=b.bowler
set s.overs_bowled=b.overs_bowled;

alter table powerplay_ball
add column runs_conceded int;

update powerplay_ball s join (select bowler,sum(runs_of_bat)+sum(wide)+sum(noballs) as runs_conceded from ipl
where ball between 0.1 and 5.6
group by bowler) b
on s.bowler=b.bowler
set s.runs_conceded=b.runs_conceded;

alter table powerplay_ball
add column economy decimal(6,2);

update powerplay_ball
set economy=runs_conceded/overs_bowled;

alter table powerplay_ball
add column dot_balls_bowled int;

update powerplay_ball s join (select bowler,count(runs_of_bat) as dot_balls_bowled from ipl
where ball between 0.1 and 5.6 and runs_of_bat=0 and wide=0 and noballs=0
group by bowler)b
on s.bowler=b.bowler
set s.dot_balls_bowled=b.dot_balls_bowled;

alter table powerplay_ball
add column dot_ball_percentage decimal(6,2);

update powerplay_ball
set dot_ball_percentage=(dot_balls_bowled/(overs_bowled*6))*100;

alter table powerplay_ball
add column extras_given int;

update powerplay_ball s join (select bowler,sum(wide)+sum(noballs) as extras_given from ipl
where ball between 0.1 and 5.6 and wide!=0 or noballs!=0
group by bowler)b
on s.bowler=b.bowler
set s.extras_given=b.extras_given;

alter table powerplay_ball
add column boundaries_conceded int;

update powerplay_ball
set extras_given=0
where extras_given is null;

update powerplay_ball s join (select bowler,sum(runs_of_bat) as boundaries_conceded from ipl
where ball between 0.1 and 5.6 and runs_of_bat in(4,6)
group by bowler) b
on s.bowler=b.bowler
set s.boundaries_conceded=b.boundaries_conceded;

alter table powerplay_ball
add column boundary_percentage decimal(6,2);

update powerplay_ball
set boundary_percentage=(boundaries_conceded/runs_conceded)*100;

alter table powerplay_ball
add column strike_rate decimal(6,2);

update powerplay_ball
set strike_rate=(overs_bowled*6)/wickets;

select * from powerplay_ball
where overs_bowled>15
order by wickets desc,economy asc,strike_rate asc,dot_ball_percentage desc,boundary_percentage asc
limit 10;