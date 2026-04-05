--예약결제
--예약번호         
--학생번호
--수강신청일 
--수강 종료일
--인원수
--예약자정보
--결제 포인트
select * from member;

--시설정보테이블
DROP TABLE facility_info CASCADE CONSTRAINTS;

CREATE TABLE facility_info (
    rsrcno         VARCHAR2(22) PRIMARY KEY,
    rsrcnm         VARCHAR2(500),
    zip            VARCHAR2(10),
    addr           VARCHAR2(1000),
    daddr          VARCHAR2(500),
    lat            VARCHAR2(500),
    lot            VARCHAR2(500),
    insturladdr    VARCHAR2(1000),
    imgfileurladdr VARCHAR2(1000)
);

SET DEFINE OFF;

INSERT INTO facility_info VALUES (
    'DF16N2654325',
    '야외운동기구',
    '31058',
    '충남 천안시 서북구 입장면 호당리 235-3',
    '일원',
    '127.237124054246',
    '36.8960982224159',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=DF16N2654325',
    'https://www.eshare.go.kr/UserPortal/Upv/116360/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'EE25K0036224',
    '운동장 (충청연수원)',
    '31048',
    '충남 천안시 서북구 직산읍 남산2길 41',
    '충청연수원',
    '127.172950022415',
    '36.8833608345875',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=EE25K0036224',
    'https://www.eshare.go.kr/UserPortal/Upv/156433/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'EE25M4616164',
    '실내체육관 (충청연수원)',
    '31048',
    '충남 천안시 서북구 직산읍 남산2길 41',
    '충청연수원',
    '127.172950022415',
    '36.8833608345875',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=EE25M4616164',
    'https://www.eshare.go.kr/UserPortal/Upv/156534/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13S1300306',
    '직산 삼은공원 게이트볼장',
    '31035',
    '충남 천안시 서북구 직산읍 삼은리 510',
    '직산 삼은공원 게이트볼장',
    '127.157957354489',
    '36.8828179808063',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13S1300306',
    'https://www.eshare.go.kr/UserPortal/Upv/58321/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13S0148861',
    '성거읍 게이트볼장',
    '31044',
    '충남 천안시 서북구 성거읍 송남리 35-7',
    '성거읍 게이트볼장',
    '127.200644128285',
    '36.869221761454',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13S0148861',
    'https://www.eshare.go.kr/UserPortal/Upv/58306/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13S0341110',
    '성환 게이트볼장',
    '31018',
    '충남 천안시 서북구 성환읍 성월리 93-26',
    '성환 게이트볼장',
    '127.134955784315',
    '36.9120797263514',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13S0341110',
    'https://www.eshare.go.kr/UserPortal/Upv/58309/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13S0556367',
    '쌍용3동 게이트볼장',
    '31166',
    '충남 천안시 서북구 쌍용동 1281',
    '쌍용3동 게이트볼장',
    '127.123706491678',
    '36.8022778206743',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13S0556367',
    'https://www.eshare.go.kr/UserPortal/Upv/58312/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13S0806224',
    '쌍용1동 게이트볼장 (쌍용 배수지 게이트볼장)',
    '31167',
    '충남 천안시 서북구 쌍용동 313-5',
    '쌍용1동 게이트볼장 (쌍용 배수지 게이트볼장)',
    '127.127027743175',
    '36.8104463170965',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13S0806224',
    'https://www.eshare.go.kr/UserPortal/Upv/58315/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD14K5813615',
    '입장 게이트볼장',
    '31056',
    '충남 천안시 서북구 입장면 기로리 354-8',
    '입장 게이트볼장',
    '127.242274470785',
    '36.9097309498513',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD14K5813615',
    'https://www.eshare.go.kr/UserPortal/Upv/58349/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N0425124',
    '북부스포츠센터 수영장',
    '31019',
    '충남 천안시 서북구 성환읍 성환1로 45',
    '북부스포츠센터',
    '127.131995092017',
    '36.8997723687957',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N0425124',
    'https://www.eshare.go.kr/UserPortal/Upv/56415/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26O2402862',
    '천안종합운동장 육상장',
    '31157',
    '충남 천안시 서북구 번영로 208 (백석동)',
    '종합운동장',
    '127.113305208572',
    '36.8191007470086',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26O2402862',
    'https://www.eshare.go.kr/UserPortal/Upv/56457/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N1414110',
    '북부스포츠센터 축구장',
    '31019',
    '충남 천안시 서북구 성환읍 성환1로 45',
    '북부스포츠센터',
    '127.131995092017',
    '36.8997723687957',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N1414110',
    'https://www.eshare.go.kr/UserPortal/Upv/56427/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N1120787',
    '북부스포츠센터 다목적실',
    '31019',
    '충남 천안시 서북구 성환읍 성환1로 45',
    '북부스포츠센터',
    '127.131995092017',
    '36.8997723687957',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N1120787',
    'https://www.eshare.go.kr/UserPortal/Upv/56424/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N0851084',
    '북부스포츠센터 다목적 체육관',
    '31019',
    '충남 천안시 서북구 성환읍 성환1로 45',
    '북부스포츠센터',
    '127.131995092017',
    '36.8997723687957',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N0851084',
    'https://www.eshare.go.kr/UserPortal/Upv/56421/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N0640847',
    '북부스포츠센터 헬스장',
    '31019',
    '충남 천안시 서북구 성환읍 성환1로 45',
    '북부스포츠센터',
    '127.131995092017',
    '36.8997723687957',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N0640847',
    'https://www.eshare.go.kr/UserPortal/Upv/56418/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26M4918248',
    '한들문화센터 헬스장',
    '31094',
    '충남 천안시 서북구 음봉로 861-50 (백석동)',
    '한들문화센터',
    '127.104606412951',
    '36.828034199931',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26M4918248',
    'https://www.eshare.go.kr/UserPortal/Upv/56412/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26M4626561',
    '한들문화센터 수영장',
    '31094',
    '충남 천안시 서북구 음봉로 861-50 (백석동)',
    '한들문화센터',
    '127.104606412951',
    '36.828034199931',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26M4626561',
    'https://www.eshare.go.kr/UserPortal/Upv/56409/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26M2604476',
    '천안축구센터 풋살장',
    '31136',
    '충남 천안시 서북구 축구센터로 150 (성정동)',
    '천안축구센터',
    '127.145765483021',
    '36.8214400797856',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26M2604476',
    'https://www.eshare.go.kr/UserPortal/Upv/56388/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26M2224006',
    '천안축구센터 인조잔디구장',
    '31136',
    '충남 천안시 서북구 축구센터로 150 (성정동)',
    '천안축구센터',
    '127.145765483021',
    '36.8214400797856',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26M2224006',
    'https://www.eshare.go.kr/UserPortal/Upv/56385/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26M2012640',
    '천안축구센터 천연잔디구장',
    '31136',
    '충남 천안시 서북구 축구센터로 150 (성정동)',
    '천안축구센터',
    '127.145765483021',
    '36.8214400797856',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26M2012640',
    'https://www.eshare.go.kr/UserPortal/Upv/56382/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'DF16N2241001',
    '야외운동기구',
    '31225',
    '충남 천안시 동남구 목천읍 도장리 387',
    '일원',
    '127.177992977134',
    '36.7460179280692',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=DF16N2241001',
    'https://www.eshare.go.kr/UserPortal/Upv/116348/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'DF16N2451662',
    '야외운동기구',
    '31246',
    '충남 천안시 동남구 성남면 용원리 370-6',
    '일원',
    '127.212980568471',
    '36.7481934266438',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=DF16N2451662',
    'https://www.eshare.go.kr/UserPortal/Upv/116354/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'BA10A0015174',
    '한국도로공사 천안지사 사옥 후면(테니스장)',
    '31067',
    '충청남도 천안시 동남구 망향로 14',
    '한국도로공사 천안지사',
    '127.16705073363659',
    '36.827467438280465',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=BA10A0015174',
    'https://www.eshare.go.kr/UserPortal/Upv/31258/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13K1044197',
    '광덕면게이트볼장(광덕게이트볼장)',
    '31221',
    '충남 천안시 동남구 광덕면 신흥리 276',
    '광덕면게이트볼장(광덕게이트볼장)',
    '127.108281917835',
    '36.6978443241836',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13K1044197',
    'https://www.eshare.go.kr/UserPortal/Upv/58001/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13K0659488',
    '풍세면게이트볼장(풍세게이트볼장)',
    '31213',
    '충남 천안시 동남구 풍세면 남관리 675',
    '풍세면게이트볼장',
    '127.128728602172',
    '36.7526485970156',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13K0659488',
    'https://www.eshare.go.kr/UserPortal/Upv/57998/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13K2459103',
    '풍세그라운드골프장',
    '31217',
    '충청남도 천안시 동남구 풍세면 풍년길 58',
    '천안시 동남구 풍세면 풍서리 676-107번지(도로명주소 없음) 풍세그라운드골프장 (풍서천 인근)',
    '127.11962499974108',
    '36.72317537871331',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13K2459103',
    'https://www.eshare.go.kr/UserPortal/Upv/58013/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q0552535',
    '동면 다목적체육관',
    '31258',
    '충남 천안시 동남구 동면 동산리 551-1',
    '동면 다목적체육관',
    '127.348319137479',
    '36.7787859537969',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q0552535',
    'https://www.eshare.go.kr/UserPortal/Upv/58065/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q0952173',
    '동면 게이트볼장',
    '31258',
    '충남 천안시 동남구 동면 동산리 551-2',
    '동면 게이트볼장',
    '127.34889643203',
    '36.7785504237092',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q0952173',
    'https://www.eshare.go.kr/UserPortal/Upv/58071/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q1342629',
    '천안정',
    '31232',
    '충청남도 천안시 동남구 목천읍 삼방로 77-31',
    '천안정',
    '127.23179162511488',
    '36.77429245568272',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q1342629',
    'https://www.eshare.go.kr/UserPortal/Upv/58079/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q1804040',
    '천안승마장',
    '31232',
    '충청남도 천안시 동남구 목천읍 독립기념관로 1',
    '천안승마장',
    '127.22863252898688',
    '36.7779661042754',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q1804040',
    'https://www.eshare.go.kr/UserPortal/Upv/58085/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q2224023',
    '목천 서리 게이트볼장',
    '31231',
    '충남 천안시 동남구 목천읍 서리 100-16',
    '목천 서리 게이트볼장',
    '127.234975194843',
    '36.783580568789',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q2224023',
    'https://www.eshare.go.kr/UserPortal/Upv/58105/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q4525063',
    '목천 체육관',
    '31246',
    '충남 천안시 동남구 목천읍 운전리 22-5',
    '목천 체육관',
    '127.23328080466',
    '36.7679534445328',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q4525063',
    'https://www.eshare.go.kr/UserPortal/Upv/58180/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q4709394',
    '병천 게이트볼장',
    '31254',
    '충남 천안시 동남구 병천면 병천리 360-1',
    '병천 게이트볼장',
    '127.302493436308',
    '36.7668472894576',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q4709394',
    'https://www.eshare.go.kr/UserPortal/Upv/58190/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q5236030',
    '아우내 체육관',
    '31256',
    '충남 천안시 동남구 병천면 탑원리 292',
    '아우내 체육관',
    '127.308897862136',
    '36.7605271772394',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q5236030',
    'https://www.eshare.go.kr/UserPortal/Upv/58223/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q5640951',
    '북면 게이트볼장',
    '31238',
    '충남 천안시 동남구 북면 오곡리 399-1',
    '북면 게이트볼장',
    '127.27368724571',
    '36.8273658628818',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q5640951',
    'https://www.eshare.go.kr/UserPortal/Upv/58246/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13Q5855589',
    '성남 게이트볼장',
    '31245',
    '충남 천안시 동남구 성남면 신사리 431-7',
    '성남 게이트볼장',
    '127.233142069418',
    '36.7433565456672',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13Q5855589',
    'https://www.eshare.go.kr/UserPortal/Upv/58256/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13R0553345',
    '수신 게이트볼장',
    '31251',
    '충남 천안시 동남구 수신면 속창리 54-22',
    '수신 게이트볼장',
    '127.2808105556',
    '36.7282383488397',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13R0553345',
    'https://www.eshare.go.kr/UserPortal/Upv/58272/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13R1040370',
    '천안 신방 체육관',
    '31203',
    '충남 천안시 동남구 신방동 115',
    '천안 신방 체육관(041-592-8556)',
    '127.129305550192',
    '36.7852073062169',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13R1040370',
    'https://www.eshare.go.kr/UserPortal/Upv/58281/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13R1308554',
    '도솔광장 인공암벽장',
    '31115',
    '충남 천안시 동남구 천안대로 844 (신부동)',
    '도솔광장 인공암벽장',
    '127.162963381378',
    '36.8243337408361',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13R1308554',
    'https://www.eshare.go.kr/UserPortal/Upv/58289/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13R1503667',
    '중앙동 게이트볼장',
    '31131',
    '충남 천안시 동남구 오룡동 111',
    '중앙동 게이트볼장',
    '127.150282907015',
    '36.8048828693391',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13R1503667',
    'https://www.eshare.go.kr/UserPortal/Upv/58294/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13R1705027',
    '원성1동 게이트볼장',
    '31125',
    '충남 천안시 동남구 원성동 31-15',
    '원성1동 게이트볼장',
    '127.162421707363',
    '36.8127383811328',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13R1705027',
    'https://www.eshare.go.kr/UserPortal/Upv/58297/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CD13R1958816',
    '천안시 장애인 종합체육관',
    '31068',
    '충남 천안시 동남구 향교1길 104-38 (유량동)',
    '천안시 장애인 종합체육관(041-558-7356)',
    '127.169320391597',
    '36.8135868856712',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CD13R1958816',
    'https://www.eshare.go.kr/UserPortal/Upv/58300/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'BA10A0015167',
    '한국기술교육대학교 운동장',
    '31253',
    '충남 천안시 동남구 병천면 충절로 1600',
    '다산정보관',
    '127.281200389603',
    '36.765104950533',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=BA10A0015167',
    'https://www.eshare.go.kr/UserPortal/Upv/69506/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N2321095',
    '태조산공원 인조잔디구장',
    '31068',
    '충남 천안시 동남구 태조산길 261 (유량동)',
    '태조산공원',
    '127.188954140775',
    '36.8220781941172',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N2321095',
    'https://www.eshare.go.kr/UserPortal/Upv/56436/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N2535948',
    '태조산공원 족구장',
    '31068',
    '충남 천안시 동남구 태조산길 261 (유량동)',
    '태조산공원',
    '127.188954140775',
    '36.8220781941172',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N2535948',
    'https://www.eshare.go.kr/UserPortal/Upv/56439/fileDetail.do?file_sn=1'
);

INSERT INTO facility_info VALUES (
    'CC26N1922175',
    '천안야구장',
    '31073',
    '충남 천안시 동남구 천안대로 320 (삼룡동)',
    '천안야구장',
    '127.164984630775',
    '36.7761051672514',
    'https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=CC26N1922175',
    'https://www.eshare.go.kr/UserPortal/Upv/56433/fileDetail.do?file_sn=1'
);

SELECT * FROM facility_info;


--시설상세정보테이블
DROP TABLE facility_info_detail CASCADE CONSTRAINTS;

CREATE TABLE facility_info_detail (
    rsrcno        VARCHAR2(1000) PRIMARY KEY,
    rsrcclscd     VARCHAR2(1000),
    rsrcclsnm     VARCHAR2(1000),
    rsrcinstcd    VARCHAR2(1000),
    rsrcinstnm    VARCHAR2(1000),
    usepsblyn     VARCHAR2(1000),
    freeyn        VARCHAR2(1000),
    rsrcintr      VARCHAR2(3000),
    atpn          VARCHAR2(4000),
    lcinf         VARCHAR2(1000),
    inqtag        VARCHAR2(1000),
    updymd        VARCHAR2(1000),
    bnrimgfileurl VARCHAR2(1000),
    delyn         VARCHAR2(1000),
    rsrcaprvyn    VARCHAR2(1000),
    sggcd         VARCHAR2(1000),
    rsvtndlsyn    VARCHAR2(1000),
    lcinsttcd     VARCHAR2(1000),
    lcinsttnm     VARCHAR2(1000),
    FOREIGN KEY ( rsrcno )
        REFERENCES facility_info ( rsrcno )
);

INSERT INTO facility_info_detail VALUES (
    'BA10A0015167',
    '010510',
    '운동장',
    '7004123',
    '한국기술교육대학교',
    'Y',
    'N',
    '&lt;수용인원&gt; 1000명 &lt;개수&gt; 1 &lt;사용요금&gt; 1시간 150,000원 &lt;평일개방&gt; 09:00~20:00 &lt;토요일개방&gt; 09:00~20:00 &lt;휴일개방&gt; 09:00~20:00'
    ,
    '<p><br></p>',
    '본관옆',
    '운동장;한국기술교육대학교;',
    '2022-03-21',
    'https://www.eshare.go.kr/UserPortal/Upv/69506/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC007699',
    '한국기술교육대학교'
);

INSERT INTO facility_info_detail VALUES (
    'BA10A0015174',
    '010503',
    '테니스장',
    'D412418',
    '한국도로공사 본부 대전충청본부 천안지사(대전충청)',
    'Y',
    'Y',
    '<span style=''font-size: 12pt;''>현재 동계 제설 작업 준비 등으로 사용이 불가능하오니 참고하시기 바랍니다.</span><br><br><br><br><strike>이용시 사전협의 &lt;수용인원&gt; 2면 &lt;개수&gt; 1 &lt;사용요금&gt; 무료&nbsp;&lt;토요일개방&gt; 09:00~18:00 &lt;휴일개방&gt; 09:00~18:00</strike>'
    ,
    '<p><br></p>',
    '사옥 후면(테니스장)',
    '',
    '2023-05-26',
    'https://www.eshare.go.kr/UserPortal/Upv/31258/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC001914',
    '한국도로공사천안지사'
);

INSERT INTO facility_info_detail VALUES (
    'CC26M2012640',
    '010501',
    '축구장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56382/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006311',
    '천안축구센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26M2224006',
    '010501',
    '축구장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56385/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006311',
    '천안축구센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26M2604476',
    '010505',
    '풋살장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56388/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006311',
    '천안축구센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26M4626561',
    '010508',
    '수영장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56409/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006312',
    '한들문화센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26M4918248',
    '010511',
    '체력단련실',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56412/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006312',
    '한들문화센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N0425124',
    '010508',
    '수영장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-06-18',
    'https://www.eshare.go.kr/UserPortal/Upv/56415/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006313',
    '북부스포츠센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N0640847',
    '010511',
    '체력단련실',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56418/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006313',
    '북부스포츠센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N0851084',
    '010512',
    '실내체육관',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56421/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006313',
    '북부스포츠센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N1120787',
    '010512',
    '실내체육관',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56424/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006313',
    '북부스포츠센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N1414110',
    '010501',
    '축구장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56427/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006313',
    '북부스포츠센터'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N1922175',
    '010509',
    '야구장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56433/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006315',
    '천안야구장'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N2321095',
    '010501',
    '축구장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-06-18',
    'https://www.eshare.go.kr/UserPortal/Upv/56436/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006316',
    '태조산공원'
);

INSERT INTO facility_info_detail VALUES (
    'CC26N2535948',
    '010502',
    '족구장',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'Y',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-06-18',
    'https://www.eshare.go.kr/UserPortal/Upv/56439/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006316',
    '태조산공원'
);

INSERT INTO facility_info_detail VALUES (
    'CC26O2402862',
    '010599',
    '기타',
    'B552815',
    '천안시시설관리공단',
    'Y',
    'N',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2021-03-26',
    'https://www.eshare.go.kr/UserPortal/Upv/56457/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006320',
    '천안종합운동장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13K0659488',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>풍세면게이트볼장(풍세게이트볼장)</p><p>이용문의</p><p>천안시 체육진흥과 ☏041-521-5759</p>',
    '<p><br></p>',
    '',
    '게이트볼장;게이트볼;풍세;천안;동남구;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/57998/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006500',
    '풍세면게이트볼장(풍세게이트볼장)'
);

INSERT INTO facility_info_detail VALUES (
    'CD13K1044197',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>광덕면게이트볼장(광덕게이트볼장)</p><p><br></p><p>이용문의 : 천안시 체육진흥과 ☏041-521-5759</p>',
    '<p><br></p>',
    '',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58001/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006501',
    '광덕면게이트볼장(광덕게이트볼장)'
);

INSERT INTO facility_info_detail VALUES (
    'CD13K2459103',
    '010514',
    '골프장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>풍세그라운드골프장<br></p><p><br></p><p>이용문의 : 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p><br></p>',
    '천안시 동남구 풍세면 풍서리 676-107번지(도로명주소 없음) 풍세그라운드골프장 (풍서천 인근)',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58013/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006503',
    '풍세그라운드골프장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q0552535',
    '010512',
    '실내체육관',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>이용문의: 천안시 체육진흥과 ☏041-521-5759</p>',
    '<p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '동면 다목적체육관',
    '동면;천안체육시설;다목적체육관;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58065/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006507',
    '동면다목적체육관'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q0952173',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>동면 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>동면 게이트볼장<br></p>',
    '동면 게이트볼장',
    '동면게이트볼장;게이트볼;동면;천안;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58071/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006509',
    '동면게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q1342629',
    '010599',
    '기타',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>천안정<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>천안정<br></p>',
    '천안정',
    '국궁;국궁장;천안정;천안국궁장;천안국궁;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58079/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006511',
    '천안정'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q1804040',
    '010599',
    '기타',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>천안승마장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p><br></p>',
    '천안승마장',
    '승마장;승마;천안승마;천안승마장;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58085/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006512',
    '천안승마장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q2224023',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>목천 서리 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p><br></p>',
    '목천 서리 게이트볼장',
    '목천;게이트볼;천안게이트볼;천안게이트볼장;목천읍;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58105/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006513',
    '목천서리게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q4525063',
    '010512',
    '실내체육관',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>목천 체육관<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p><br></p>',
    '목천 체육관',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58180/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006514',
    '목천체육관'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q4709394',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>병천 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p><br></p>',
    '병천 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58190/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006516',
    '병천게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q5236030',
    '010512',
    '실내체육관',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>아우내 체육관<br></p><p>이용문의: 사적관리과 시설팀 ☏<span style=''white-space: nowrap;''>041-521-2827</span></p>',
    '<p>아우내 체육관<br></p><p>이용문의: 사적관리과 시설팀 ☏<span style=''white-space: nowrap;''>041-521-2827</span></p>',
    '아우내 체육관',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58223/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006519',
    '아우내체육관'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q5640951',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>북면 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>북면 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759</p>',
    '북면 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58246/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006522',
    '북면게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13Q5855589',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>성남 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p><br></p>',
    '성남 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58256/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006524',
    '성남게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13R0553345',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>수신 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>수신 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759</p>',
    '수신 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58272/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006528',
    '수신게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13R1040370',
    '010512',
    '실내체육관',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>천안 신방 체육관(<span style=''background-color: rgb(255, 255, 255); color: rgb(32, 32, 32); font-size: 13px;''>041-592-8556)</span> </p><p><span style=''background-color: rgb(255, 255, 255); color: rgb(32, 32, 32); font-size: 13px;''><br></span></p><p><span style=''background-color: rgb(255, 255, 255);''><span style=''color: rgb(32, 32, 32); ''><span style=''font-size: 13px;''>이용문의: 신방체육관 천안시체육회 ☏041-592-8556</span></span> </span></p>'
    ,
    '<p>천안 신방 체육관(<span style=''background-color: rgb(255, 255, 255); color: rgb(32, 32, 32); font-size: 13px;''>041-592-8556)</span> </p><p><span style=''background-color: rgb(255, 255, 255); color: rgb(32, 32, 32); font-size: 13px;''><br></span></p><p><span style=''background-color: rgb(255, 255, 255);''><span style=''color: rgb(32, 32, 32); ''><span style=''font-size: 13px;''>이용문의: 신방체육관 천안시체육회 ☏041-592-8556</span></span></span></p>'
    ,
    '천안 신방 체육관(041-592-8556)',
    '탁구;천안탁구;천안탁구장;게이트볼;신방동;',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58281/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006531',
    '천안신방체육관'
);

INSERT INTO facility_info_detail VALUES (
    'CD13R1308554',
    '010599',
    '기타',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p style=''margin-left: 0px;''><span style=''color: rgb(255, 0, 0);''></span>도솔광장 인공암벽장은 현재 실내인공암벽장만 운영 중이며, 코로나 의심증상이 있는 경우 이용이 불가능합니다.<br><span style=''color: rgb(255, 0, 0); font-size: 10pt;''>※</span><span style=''font-size: 10pt;''> </span><span style=''color: rgb(255, 0, 0); font-size: 11pt;''>사용 전 신청서식(ⓛ시설물사용신청서, ②이용수칙, ③출입자명부)을 작성하신 다음 담당자 메일 혹은 팩스로 <br>&nbsp; &nbsp;접수하셔야 예약승인이 완료됩니다. (서명 또는 날인은 자필로 작성하셔야 합니다.)</span><br><br>1. 이용시간<br>&nbsp; 1) 1부&nbsp;:&nbsp;10:00 ~ 13:00<br>&nbsp; 2) 2부 : 14:00 ~ 17:00<br><br>2.&nbsp;이용 가능 인원 : 최대 4인<br><br>3. 이용금액 : 무료&nbsp;&nbsp;<br></p>'
    ,
    '<p>도솔광장 인공암벽장은 현재 실내인공암벽장만 운영 중에 있으며, 코로나 의심증상이 있는 경우 이용이 불가능합니다.<br><span style=''color: rgb(255, 0, 0); font-size: 10pt;''>※</span><span style=''font-size: 10pt;''>&nbsp;</span><span style=''color: rgb(255, 0, 0); font-size: 11pt;''>사용 전 신청서식(ⓛ시설물사용신청서, ②이용수칙, ③출입자명부)을 작성하신 다음 담당자 메일 혹은 팩스로<br>&nbsp; &nbsp;접수하셔야 예약승인이 완료됩니다.&nbsp;</span><span style=''color: rgb(255, 0, 0); font-size: 14.6667px;''>(서명 또는 날인은 자필로 작성하셔야 합니다.)</span><span style=''color: rgb(255, 0, 0); font-size: 11pt;''><br></span><br>&lt;주의사항&gt;<br>1. 실내 인공암벽장을 이용 시 안전장비를 반드시 착용하여야 함<br>2. 시설물 사용시간 준수 및 5인 이상 이용금지<br>3. 이용 중 마스크를 반드시 착용하여야 함<br>4. 시설물 사용 시 발생되는 도난, 시설물 파손 및 훼손에 대한 변상 및 원상복구<br>5. 체육시설 이용 중 발생하는 모든 사고에 대한 책임은&nbsp;사용자에게 있습니다.&nbsp;<br></p>'
    ,
    '도솔광장 인공암벽장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58289/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006533',
    '도솔광장인공암벽장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13R1503667',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>중앙동 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>중앙동 게이트볼장<br></p>',
    '중앙동 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58294/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006534',
    '중앙동게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13R1705027',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>원성1동 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>원성1동 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759</p>',
    '원성1동 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58297/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006535',
    '원성1동게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13R1958816',
    '010512',
    '실내체육관',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>천안시 장애인 종합체육관(041-558-7356)<br></p>',
    '<p>천안시 장애인 종합체육관(041-558-7356)<br></p>',
    '천안시 장애인 종합체육관(041-558-7356)',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58300/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'N',
    'LC006536',
    '천안시장애인종합체육관(041-558-7356)'
);

INSERT INTO facility_info_detail VALUES (
    'CD13S0148861',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>성거읍 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>성거읍 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '성거읍 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58306/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006538',
    '성거읍게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13S0341110',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>성환 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>성환 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '성환 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58309/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006539',
    '성환게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13S0556367',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>쌍용3동 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>쌍용3동 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '쌍용3동 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58312/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006540',
    '쌍용3동게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD13S0806224',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>쌍용1동 게이트볼장</p><p>(쌍용 배수지 게이트볼장)</p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>쌍용1동 게이트볼장</p><p>(쌍용 배수지 게이트볼장)</p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '쌍용1동 게이트볼장 (쌍용 배수지 게이트볼장)',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58315/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006541',
    '쌍용1동게이트볼장(쌍용배수지게이트볼장)'
);

INSERT INTO facility_info_detail VALUES (
    'CD13S1300306',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>직산 삼은공원 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '<p>직산 삼은공원 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759<br></p>',
    '직산 삼은공원 게이트볼장',
    '',
    '2023-05-25',
    'https://www.eshare.go.kr/UserPortal/Upv/58321/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006543',
    '직산삼은공원게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'CD14K5813615',
    '010513',
    '게이트볼장',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p>입장 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759</p>',
    '<p>입장 게이트볼장<br></p><p>이용문의: 천안시 체육진흥과 ☏041-521-5759</p>',
    '입장 게이트볼장',
    '',
    '2023-05-24',
    'https://www.eshare.go.kr/UserPortal/Upv/58349/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC006545',
    '입장게이트볼장'
);

INSERT INTO facility_info_detail VALUES (
    'DF16N2241001',
    '010516',
    '야외운동시설',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2023-06-20',
    'https://www.eshare.go.kr/UserPortal/Upv/116348/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'Y',
    'LC011404',
    '목천읍도장리387'
);

INSERT INTO facility_info_detail VALUES (
    'DF16N2451662',
    '010516',
    '야외운동시설',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2023-06-20',
    'https://www.eshare.go.kr/UserPortal/Upv/116354/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44131',
    'Y',
    'LC014119',
    '성남면용원리372-7'
);

INSERT INTO facility_info_detail VALUES (
    'DF16N2654325',
    '010516',
    '야외운동시설',
    '4490399',
    '충청남도 천안시 복지문화국 체육진흥과',
    'Y',
    'Y',
    '<p><br></p>',
    '<p><br></p>',
    '',
    '',
    '2023-06-20',
    'https://www.eshare.go.kr/UserPortal/Upv/116360/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'Y',
    'LC011408',
    '입장면호당리235-3'
);

INSERT INTO facility_info_detail VALUES (
    'EE25K0036224',
    '010510',
    '운동장',
    'D555075',
    '중소벤처기업진흥공단 충청연수원',
    'Y',
    'N',
    '<p><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>&lt; 수용인원 &gt; 80명<br>· 상업적 목적을 제외한 경우에 허용</span><br style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>· 중소벤처기업 재직자 교육시설로, 교육과정 운영에 지장이 없는 범위에서 이용 가능</span> </p>'
    ,
    '<p><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>· 기본(3시간) 1,000,000원</span><br style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>· 추가 1시간당 200,000원</span><br style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>* 부가세 별도</span> </p>'
    ,
    '',
    '',
    '2023-05-26',
    'https://www.eshare.go.kr/UserPortal/Upv/156433/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC014658',
    '충청연수원'
);

INSERT INTO facility_info_detail VALUES (
    'EE25M4616164',
    '010512',
    '실내체육관',
    'D555075',
    '중소벤처기업진흥공단 충청연수원',
    'Y',
    'N',
    '<p><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>&lt; 수용인원 &gt; 80명<br>· 상업적 목적을 제외한 경우에 허용</span><br style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>· 중소벤처기업 재직자 교육시설로, 교육과정 운영에 지장이 없는 범위에서 이용 가능</span> </p>'
    ,
    '<p><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>· 기본(3시간) 300,000원</span><br style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>· 추가 1시간당 50,000원</span><br style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''><span style=''color: rgb(102, 102, 102); font-size: medium; background-color: rgb(255, 255, 255);''>* 부가세 별도</span> </p>'
    ,
    '',
    '',
    '2023-05-26',
    'https://www.eshare.go.kr/UserPortal/Upv/156534/fileDetail.do?file_sn=1',
    'N',
    'Y',
    '44133',
    'N',
    'LC014658',
    '충청연수원'
);

SELECT * FROM facility_info_detail;

-- 예약 정보 테이블
DROP TABLE reservation_info;

CREATE TABLE reservation_info (
    rsvtno         NUMBER PRIMARY KEY,  --예약번호
    rgsrdate       DATE,  --등록일
    deaddate       DATE,  --마감일
    todate         DATE,  --사용하는 날
    rsvttime       NUMBER,   --사용하는 시간
    rsrcid         VARCHAR2(1000),  -- 개설자 아이디
    rsvfnm         VARCHAR2(1000), --시설이름
    category       VARCHAR2(500),  -- 종목
    totalpeoplecnt NUMBER,  -- 참가 인원 숫자
    jidone         VARCHAR2(100),  -- 참가자1
    jidtwo         VARCHAR2(100),  -- 참가자2
    jidthree       VARCHAR2(100),  -- 참가자3
    status         NUMBER, -- 상태
    approval       VARCHAR2(2)   --담당자 승인여부
);

CREATE SEQUENCE reservation_info_no_seq START WITH 0 MINVALUE 0 INCREMENT BY 1;

COMMIT;

DROP SEQUENCE member_no_seq;

CREATE SEQUENCE member_no_seq START WITH 0 MINVALUE 0 INCREMENT BY 1;

SELECT member_no_seq.NEXTVAL FROM dual;

--회원정보테이블
DROP TABLE member;

CREATE TABLE member (
    member_no    NUMBER,
    login_id     VARCHAR2(30 BYTE) PRIMARY KEY,
    password     VARCHAR2(30 BYTE),
    member_name  VARCHAR2(30 BYTE),
    birth        DATE,
    email        VARCHAR2(50 BYTE),
    phone_num    VARCHAR2(22 BYTE),
    join_date    DATE DEFAULT sysdate,
    user_code    VARCHAR2(6 BYTE),
    point        NUMBER,
    report_count NUMBER DEFAULT 0
);

SELECT * FROM member;

--게시판테이블

DROP SEQUENCE board_infos_seq;

CREATE SEQUENCE board_infos_seq INCREMENT BY 1 START WITH 1 MINVALUE 1 MAXVALUE 9999999999 NOCYCLE NOCACHE;

DROP TABLE board_infos CASCADE CONSTRAINTS;
--글번호
--작성자(아이디)
--작성날짜
--제목
--내용
--추천수
--신고수
--조회수
DROP SEQUENCE board_infos_seq;
DROP TABLE board_infos;

select *from member;

CREATE SEQUENCE board_infos_seq 
INCREMENT BY 1 
START WITH 1 
MINVALUE 1 
MAXVALUE 9999999999 
NOCYCLE
NOCACHE;

CREATE TABLE board_infos (
    postno NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    title VARCHAR2(150) not null,
    content VARCHAR2(2000),
    hashtag VARCHAR2(100),
    writer VARCHAR2(50),
    updatedate DATE DEFAULT SYSDATE,
    changedate DATE DEFAULT SYSDATE,
    recommend NUMBER default 0,
    report NUMBER default 0,
    viewCnt NUMBER DEFAULT 0,
    CONSTRAINT pk_board_infos PRIMARY KEY (postno),
    FOREIGN KEY (writer) REFERENCES member (login_id)
    ON DELETE CASCADE
);

ALTER TABLE board_infos MODIFY (
    postno
        GENERATED AS IDENTITY ( START WITH 1 )
);

SELECT * FROM board_infos;

COMMIT;

--댓글테이블
DROP SEQUENCE reply_seq;

CREATE SEQUENCE reply_seq INCREMENT BY 1 START WITH 1 MINVALUE 1 MAXVALUE 9999999999 NOCYCLE NOCACHE;

DROP TABLE reply CASCADE CONSTRAINTS;

-- 댓글 테이블
create table reply(
    replynumber number not null primary key, 
	postno number , --  board_infos랑 연결할 거
	replytext varchar2(1000)  ,
	replyname varchar2(20)  ,
	replyUserID varchar2(50)  ,
	secretreply number(2)  ,
    recommend number default 0,
    report number default 0,
	changedate date default sysdate, 
	updatedate date default sysdate,
    FOREIGN KEY (postno) REFERENCES board_infos (POSTNO)
    ON DELETE CASCADE
);

-- 신고 추천 정보 테이블

DROP TABLE board_opinions CASCADE CONSTRAINTS;

CREATE TABLE board_opinions (
    postno       NUMBER,
    opinion_type NUMBER,
    login_id     VARCHAR2(30 BYTE) NOT NULL,
    CONSTRAINT boatd_likes_pk PRIMARY KEY ( postno,
                                            opinion_type,
                                            login_id ),
    FOREIGN KEY ( postno )
        REFERENCES board_infos ( postno )
);

commit;
select * from board_opinions;

