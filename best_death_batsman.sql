-- Runs scored by each batsman in death overs
select striker as "Batsman",sum(runs_of_bat) as "Total runs in death overs" from ipl
where ball between 16.1 and 19.6 and wide=0
group by striker
order by sum(runs_of_bat) desc;

-- Balls faced by each batsman in death overs
select striker as 'Batsman',count(striker) as 'Balls faced' from ipl
where ball between 16.1 and 19.6 and wide=0
group by striker
order by count(striker) desc;

-- Creating new table for storing those values 
create table death_bat as 
select striker as Batsman,count(striker) as Balls_faced,sum(runs_of_bat) as Total_runs from ipl
where ball between 16.1 and 19.6 and wide=0
group by striker
order by sum(runs_of_bat) desc,count(striker) desc;

set sql_safe_updates=0;

-- Adding another column for calculating strikerate
alter table death_bat
add column Strikerate decimal(6,2);

-- Updating Strike rate for each batsman
update death_bat
set Strikerate=(Total_runs/Balls_faced)*100;

-- Calculating boundary percentage
select striker as "Batsman",sum(runs_of_bat) as "Total runs in boundaries in powerplay" from ipl
where ball between 16.1 and 19.6 and wide=0 and (runs_of_bat=4 or runs_of_bat=6)
group by striker
order by sum(runs_of_bat) desc;

-- Adding column:runs scored in boundaries
alter table death_bat
add column Boundary_runs int;

-- Adding that column to existing one
update death_bat s join(select striker,sum(runs_of_bat) as total_boundary_runs from ipl
where ball between 6.1 and 15.6 and wide=0 and (runs_of_bat=4 or runs_of_bat=6)
group by striker) b
on s.batsman=b.striker
set s.boundary_runs=b.total_boundary_runs;

-- Setting null values to zero
update death_bat
set boundary_runs=0
where boundary_runs IS NULL;

-- Add boundary percentage column
alter table death_bat
add column boundary_percentage decimal(6,2);

-- Updating percentage values
update death_bat
set boundary_percentage=(boundary_runs/total_runs)*100
where total_runs!=0;

-- Setting null values to zero
update death_bat
set boundary_percentage=0
where boundary_percentage is null;

-- Scores of powerplay by each batter in each match and store it in new table
create table c as select striker,match_no,sum(runs_of_bat) as each_match_score from ipl
where ball between 16.1 and 19.6 and wide=0
group by striker,match_no;

select * from c;

-- Adding column:Number of matches played
alter table death_bat
add column matches_played int;

-- Updating it to the table
update death_bat b join(select count(distinct match_no) as matches_played,striker from ipl
where ball between 16.1 and 19.6 and wide=0
group by striker) s
on b.batsman=s.striker
set b.matches_played=s.matches_played;


-- Query to count number of time player scores above 30 inside powerplay 
select striker,count(striker)from c
where each_match_score>20
group by striker;

-- Adding column:Matches above 30 score
alter table death_bat
add column matches_above_20 int;


-- Updating it to the table
update death_bat s join(select striker,count(striker) as above from c
where each_match_score>30
group by striker) b
on s.batsman=b.striker
set s.matches_above_20=b.above;

-- Updating null values to zero
update death_bat
set matches_above_20=0
where matches_above_20 is null;

-- Adding column consistency
alter table death_bat
add column consistency decimal(6,2);

-- Updating consistency
update death_bat
set consistency=(matches_above_20/matches_played)*100;

-- Add column:dot balls
alter table death_bat
add column dot_balls int;

-- Updating it to the table
update death_bat s join(select striker,count(runs_of_bat) as total_dot_balls from ipl
where ball between 16.1 and 19.6 and wide=0 and (runs_of_bat=0)
group by striker) b
on s.batsman=b.striker
set s.dot_balls=b.total_dot_balls;

-- Adding column dot ball percentage
alter table death_bat
add column dot_ball_percentage decimal(6,2);

-- Updating dot ball percentage
update death_bat
set dot_ball_percentage=(dot_balls/balls_faced)*100;


-- Selecting top 10 best batsman in middle overs
select batsman from death_bat
where Balls_faced>50
order by strikerate desc,dot_ball_percentage asc,boundary_percentage desc,consistency desc,total_runs desc
limit 10;

select * from death_bat
where total_runs>100
order by strikerate desc,dot_ball_percentage asc,boundary_percentage desc,consistency desc,total_runs desc
limit 10;