SELECT
    con.contest_id, 
    con.hacker_id, 
    con.name,
    SUM(s_ts),
    SUM(s_tas),
    SUM(s_tv),
    SUM(s_tuv)
FROM    Contests con
JOIN    Colleges col    ON      con.contest_id = col.contest_id
JOIN    Challenges chal ON      chal.college_id = col.college_id
LEFT JOIN 
    (SELECT challenge_id, SUM(total_views) AS s_tv, SUM(total_unique_views) AS s_tuv FROM View_Stats GROUP BY challenge_id) vs ON chal.challenge_id = vs.challenge_id
LEFT JOIN 
    (SELECT challenge_id, SUM(total_submissions) AS s_ts, SUM(total_accepted_submissions) AS s_tas FROM Submission_Stats GROUP BY challenge_id) ss ON chal.challenge_id = ss.challenge_id
GROUP BY    
    con.contest_id, 
    con.hacker_id, 
    con.name
HAVING
    SUM(s_tv) != 0 or
    SUM(s_tuv) != 0 or
    SUM(s_ts) != 0 or
    SUM(s_tas) != 0
ORDER BY contest_id;