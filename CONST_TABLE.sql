create table CONST_NAFP_BCCCPS_BOU_DAY
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_BCCCPS_BOU_DAY_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_BCCCPS_BOU_DAY_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_BCCCSM_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_BCCCSM_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_BCCCSM_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_BCCCSM_GLB_MUL_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_BCCCSM_GLB_MUL_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_BCCCSM_GLB_MUL_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_BCCCSM11_MUL_MON
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_BCCCSM11_MUL_MON_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_BCCCSM11_MUL_MON_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_BCCCSM12_MUL_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_BCCCSM12_MUL_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_BCCCSM12_MUL_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_CFSV2_GLB_MUL_HH_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_CFSV2_GLB_MUL_HH_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_CFSV2_GLB_MUL_HH_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_CRA_GLB_BOU_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_CRA_GLB_BOU_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_CRA_GLB_BOU_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_CRA_GLB_MUL_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_CRA_GLB_MUL_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_CRA_GLB_MUL_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_DERF2_GLB_MUL_HH_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_DERF2_GLB_MUL_HH_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_DERF2_GLB_MUL_HH_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_EC1_45_GLB_MUL_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_EC1_45_GLB_MUL_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_EC1_45_GLB_MUL_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_GODAS_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_GODAS_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_GODAS_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_GODAS_GLB_BOU_PEN_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_GODAS_GLB_BOU_PEN_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_GODAS_GLB_BOU_PEN_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_NCEP_GLB_BOU_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_NCEP_GLB_BOU_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_NCEP_GLB_BOU_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_NCEP_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_NCEP_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_NCEP_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_NCEP_GLB_MUL_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_NCEP_GLB_MUL_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_NCEP_GLB_MUL_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_NAFP_NCEP_GLB_MUL_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_NAFP_NCEP_GLB_MUL_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_NAFP_NCEP_GLB_MUL_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_OCEA_HADISST_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_OCEA_HADISST_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_OCEA_HADISST_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_OCEA_NOAASI_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_OCEA_NOAASI_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_OCEA_NOAASI_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_OCEA_NOAAV2_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_OCEA_NOAAV2_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_OCEA_NOAAV2_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_OCEA_NOAAV2H_GLB_BOU_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_OCEA_NOAAV2H_GLB_BOU_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_OCEA_NOAAV2H_GLB_BOU_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_sate_noaaolr_glb_bou_day
(
	D_RECORD_ID serial not null
		constraint CONST_sate_noaaolr_glb_bou_day_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_sate_noaaolr_glb_bou_day_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_sate_noaav2h_glb_bou_day
(
	D_RECORD_ID serial not null
		constraint CONST_sate_noaav2h_glb_bou_day_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_sate_noaav2h_glb_bou_day_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_surf_ncep_glb_bou_day
(
	D_RECORD_ID serial not null
		constraint CONST_surf_ncep_glb_bou_day_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_surf_ncep_glb_bou_day_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_UPAR_NCEP_GLB_MUL_DAY
(
	D_RECORD_ID serial not null
		constraint CONST_UPAR_NCEP_GLB_MUL_DAY_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_UPAR_NCEP_GLB_MUL_DAY_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_UPAR_CRA_GLB_MUL_DAY
(
	D_RECORD_ID serial not null
		constraint CONST_UPAR_CRA_GLB_MUL_DAY_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_UPAR_CRA_GLB_MUL_DAY_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_CPC_GLB_BOU_DAY
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_CPC_GLB_BOU_DAY_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_CPC_GLB_BOU_DAY_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SATE_NOAAOLR_GLB_BOU_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SATE_NOAAOLR_GLB_BOU_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SATE_NOAAOLR_GLB_BOU_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_BCCCPSV3_GLB_MUL_DAY
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_BCCCPSV3_GLB_MUL_DAY_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_BCCCPSV3_GLB_MUL_DAY_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_CODAS_GLB_BOU_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_CODAS_GLB_BOU_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_CODAS_GLB_BOU_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_CPC_GLB_BOU_DAY_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_CPC_GLB_BOU_DAY_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_CPC_GLB_BOU_DAY_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_ECMWF_MUL_WEEK
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_ECMWF_MUL_WEEK_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_ECMWF_MUL_WEEK_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_GFS_MUL_DAY
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_GFS_MUL_DAY_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_GFS_MUL_DAY_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_NOAACMAP_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_NOAACMAP_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_NOAACMAP_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_NOAAGPCP_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_NOAAGPCP_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_NOAAGPCP_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_NOAAV5_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_NOAAV5_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_NOAAV5_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_SURF_RUTGERSSNOW_GLB_BOU_MON_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_SURF_RUTGERSSNOW_GLB_BOU_MON_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_SURF_RUTGERSSNOW_GLB_BOU_MON_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);

create table CONST_OCEA_NOAAV2H_GLB_BOU_PEN_TAB
(
	D_RECORD_ID serial not null
		constraint CONST_OCEA_NOAAV2H_GLB_BOU_PEN_TAB_pkey
		primary key,
	D_DATA_ID char(50),
	D_IYMDHM date,
	D_RYMDHM date,
	D_UPDATE_TIME timestamp,
	D_DATETIME numeric,
	D_DATETIME_MET mettime,
	V_EVN numeric,
	D_FORETIME numeric,
	D_FORETIME_MET mettime,
	V_LEVEL numeric,
	V_LATEND numeric,
	V_LATSTART numeric,
	V_LONEND numeric,
	V_LONSTART numeric,
	V_ELE_CODE char(50),
	V_DATA grid,
	GEOM geometry, CONST_TYPE int,
	constraint CONST_OCEA_NOAAV2H_GLB_BOU_PEN_TAB_INDEX
		unique (D_DATETIME, V_ELE_CODE, V_LEVEL, V_EVN)
);