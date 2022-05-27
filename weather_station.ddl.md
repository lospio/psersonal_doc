```sql
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS weather_station;
--
-- Name: weather_station; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE weather_station WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'zh_CN.UTF-8';


ALTER DATABASE weather_station OWNER TO postgres;

\connect weather_station

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test (
    station_id_c text,
    station_name text,
    prs double precision,
    prs_sea double precision,
    win_s_gust_max double precision,
    win_d_gust_max double precision,
    win_d_inst double precision,
    win_s_inst double precision,
    win_d_avg_1mi double precision,
    win_s_avg_1mi double precision,
    win_d_avg_2mi double precision,
    win_s_avg_2mi double precision,
    win_d_avg_10mi double precision,
    win_s_avg_10mi double precision,
    win_d_s_max double precision,
    tem double precision,
    dpt double precision,
    gst_5cm double precision,
    gst_10cm double precision,
    gst_15cm double precision,
    gst_20cm double precision,
    gst_40cm double precision,
    gst_80cm double precision,
    gst_160cm double precision,
    gst_320cm double precision,
    gst double precision,
    lgst double precision,
    rhu double precision,
    vap double precision,
    snow_depth double precision,
    evp_big double precision,
    vis_hor_1mi double precision,
    vis_hor_10mi double precision,
    clo_cov double precision,
    clo_height_lom double precision,
    datetime timestamp without time zone
);


ALTER TABLE public.test OWNER TO postgres;

--
-- PostgreSQL database dump complete
--


```