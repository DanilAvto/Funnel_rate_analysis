-- step 1: select all the pageviews for relevant sessions
-- step 2: identify each relevant pageview as the specific funnel step
-- step 3: create the session-level conversion funnel view
-- step 4: aggregate the data to assess funnel performance

select
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url='/products' then 1 else 0 end as product_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
from
website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01' -- random timeframe
and website_pageviews.pageview_url in('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
1,3;

select
website_session_id,
Max(product_page) as product_made_it,
Max(mrfuzzy_page) as mrfuzzy_made_it,
Max(cart_page) as cart_made_it
from(select
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url='/products' then 1 else 0 end as product_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
from
website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01' -- random timeframe
and website_pageviews.pageview_url in('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
1,3) as pageview_level
group by website_session_id;

create temporary table session_level_made_it_flags_demo
select
website_session_id,
Max(product_page) as product_made_it,
Max(mrfuzzy_page) as mrfuzzy_made_it,
Max(cart_page) as cart_made_it
from(select
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url='/products' then 1 else 0 end as product_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
from
website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01' -- random timeframe
and website_pageviews.pageview_url in('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
1,3) as pageview_level
group by website_session_id;

select
Count(distinct website_session_id) as sessions,
Count( distinct case when product_made_it = 1 then website_session_id else null end)/Count(distinct website_session_id) as lander_clickthrough_rate,
 Count( distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)/ Count( distinct case when product_made_it = 1 then website_session_id else null end)as product_clickthrough_rate,
 Count( distinct case when cart_made_it = 1 then website_session_id else null end)/Count( distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as mrfuzzy_clickthrough_rate
from session_level_made_it_flags_demo;