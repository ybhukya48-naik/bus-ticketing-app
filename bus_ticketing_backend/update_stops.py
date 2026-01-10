import csv
import sys

def update_stops(existing_file, new_data_str):
    existing_stops = []
    existing_header = None
    
    with open(existing_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        existing_header = next(reader)
        for row in reader:
            if row:
                existing_stops.append(row)

    # Create a lookup for updates
    updates = {}
    new_lines = new_data_str.strip().split('\n')
    if new_lines[0].strip().startswith('stop_id'):
        new_lines = new_lines[1:]
    
    for line in new_lines:
        parts = [p.strip() for p in line.split(',')]
        if len(parts) >= 4:
            updates[parts[0]] = parts
        elif len(parts) == 2:
            # Handle cases like "960,Sagar" by finding the existing one
            pass

    updated_count = 0
    added_count = 0
    
    final_stops = []
    seen_ids = set()
    
    # Update existing ones
    for row in existing_stops:
        stop_id = row[0]
        if stop_id in updates:
            if row != updates[stop_id]:
                final_stops.append(updates[stop_id])
                updated_count += 1
            else:
                final_stops.append(row)
            seen_ids.add(stop_id)
        else:
            final_stops.append(row)
            seen_ids.add(stop_id)
            
    # Add new ones that weren't in existing
    for stop_id, row in updates.items():
        if stop_id not in seen_ids:
            final_stops.append(row)
            added_count += 1
            seen_ids.add(stop_id)

    # Write back to file
    with open(existing_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(existing_header)
        writer.writerows(final_stops)
    
    print(f"Updated {updated_count} stops.")
    print(f"Added {added_count} new stops.")

new_data = """
 348,koti,17.38471,78.48426 
 301,Abids GPO,17.38781,78.47613 
 487,Annapurna Hotel,17.38903,78.4734 
 302,Nampally Public Garden,17.39499,78.47036 
 303,Assembly,17.39992,78.47028 
 304,Lakdikapool,17.40322,78.46536 
 305,Mahavir Hospital JNTU,17.40333,78.45635 
 306,Masab Tank,17.40429,78.45185 
 307,Pension Office,17.40785,78.45095 
 308,Banjara Hills Road No 12,17.40821,78.43877 
 309,Durga Enclave/V R Building,17.41204,78.4318 
 488,ACB Office,17.4127,78.4292 
 310,MLA colony,17.41405,78.42415 
 311,Apollo,17.41805,78.41336 
 312,Journalist Colony,17.42133,78.41073 
 334,Jubilee Hills Checkpost,17.42869,78.41307 
 314,Usha kiran,17.42979,78.41068 
 332,Peddamma Temple,17.43111,78.4074 
 331,Madhapur PS,17.43944,78.39594 
 317,Madhapur petrol bunk,17.44093,78.39126 
 318,Madhapur Image Hospital,17.44648,78.38487 
 319,Hitech Shilparamam,17.45238,78.38021 
 320,Hitex Kaman,17.45547,78.37764 
 321,Satyam/Jayabheri,17.45771,78.37153 
 322,Kothaguda X Road,17.45951,78.36616 
 323,Kondapur,17.46498,78.36409 
 398,lingampally,17.495,78.31592 
 906,lingampally railway station,17.48287,78.32048 
 908,alind,17.47653,78.32493 
 1061,hcu depot,17.46875,78.3311 
 909,hcu main gate,17.46162,78.33612 
 910,masjid banda,17.45999,78.33768 
 1064,gachibowli stadium,17.45163,78.34518 
 911,iiit,17.44493,78.35318 
 913,indira nagar,17.44101,78.36046 
 915,gachibowli X road,17.43836,78.36443 
 916,telecom nagar,17.43528,78.36809 
 917,nccb,17.428,78.37538 
 918,khajaguda x road,17.42253,78.38252 
 919,darga,17.41309,78.39499 
 1067,sheikpetnala,17.40611,78.4039 
 920,brindavan colony,17.40345,78.40937 
 802,tolichowki,17.39863,78.41693 
 803,nanal nagar,17.39633,78.42721 
 1065,rethibowli,17.39623,78.4306 
 804,mehdipatnam,17.39505,78.44017 
 816,sd hospital,17.39873,78.44518 
 817,nmdc,17.39888,78.4497 
 352,Mahavir Hospital,17.40287,78.4582 
 492,bjr college,17.40477,78.46104 
 344,telephone bhavan,17.40714,78.4663 
 883,secretariat,17.40807,78.47198 
 884,liberty,17.40635,78.47817 
 885,himayat nagar,17.40328,78.48265 
 888,narayanaguda,17.4003,78.49059 
 956,barkathapura,17.39593,78.49717 
 447,fever hospital,17.39553,78.50222 
 924,tilak nagar,17.39421,78.5083 
 887,6 number,17.39174,78.51236 
 929,amberpet,17.39234,78.51688 
 930,amberpet gandhi statue,17.3927,78.51962 
 931,irani hotel,17.39401,78.52313 
 932,t v studio,17.39653,78.52933 
 933,ramanthapur colony,17.39793,78.53267 
 934,ramanthapur public school,17.39956,78.53708 
 935,church,17.40117,78.54349 
 936,modern bakery,17.40137,78.54997 
 937,uppal x road,17.40159,78.55916 
 938,uppal gandhi statue,17.40162,78.56558 
 939,uppal bus stop,17.40165,78.56838 
 1040,JBS,17.44746,78.49645 
 2105,YMca,17.44311,78.49896 
 813,sangeeth,17.44116,78.50558 
 1574,secunderabaD,17.43695,78.50511 
 1398,rethifile busstation,17.43478,78.50508 
 1399,chilkalguda,17.43183,78.50565 
 1400,bhoiguda,17.42738,78.50205 
 1401,gandhi hospital,17.42396,78.50192 
 1208,Musheerabad Police station,17.4188,78.49984 
 1209,Raja Delux,17.41514,78.49816 
 1214,RTC X ROAD,17.40862,78.49762 
 368,rtc x road / Bus Bhavan,17.40626,78.49846 
 927,vst,17.40478,78.50243 
 1402,ccs office,17.40388,78.50478 
 1329,Nallakunta,17.39884,78.5059 
 448,Fever Hospital,17.39509,78.50185 
 1568,tourist hotel,17.39093,78.49645 
 1466,Kachiguda station,17.39058,78.49894 
 1403,nimboli adda,17.38444,78.4938 
 1580,CHaderghat,17.38134,78.49276 
 749,MGBS,17.37774,78.48277 
 1583,AFzalgunj,17.37294,78.47673 
 1404,madina,17.36848,78.4738 
 1894,CITY college,17.36793,78.46838 
 1406,puranapool,17.36491,78.45706 
 1407,bahadurpura,17.35863,78.4551 
 1408,zoo park,17.35058,78.45243 
 1409,tad bun,17.34533,78.45085 
 1410,water filter,17.34049,78.45063 
 1411,hasan nagar,17.33684,78.44956 
 1413,hasan nagar x road,17.33489,78.44341 
 1414,npa,17.33135,78.43818 
 1415,shivarampally x road,17.32405,78.43363 
 1417,aramghar x road,17.32145,78.43259 
 1418,durga nagar,17.31819,78.4374 
 1419,Katedan,17.31191,78.4384 
 1420,madhuban colony,17.30135,78.43795 
 2474,Sriram colony,17.29322,78.44179 
 343,lakdikapool,17.40593,78.46313 
 345,assembly/air,17.40216,78.46871 
 501,nizam college,17.39776,78.47527 
 346,Abids Grammer School,17.39334,78.47627 
 347,central Bank,17.38545,78.48142 
 354,Chikkadapalli,17.40201,78.49511 
 355,Narayanaguda,17.39883,78.49402 
 356,YMCA,17.39591,78.49085 
 1210,Sultana Bazar,17.38793,78.48727 
 469,koti womens college,17.3849,78.48817 
 470,chaderghat,17.37729,78.494 
 471,nalgonda X road,17.3754,78.49833 
 472,malakpet gunj,17.37339,78.50453 
 473,malakpet super bazaar,17.37247,78.50939 
 475,moosharambagh,17.36972,78.51615 
 2141,Dilsukh Nagar Depot,17.36962,78.52541 
 787,Secunderabad,17.43451,78.50125 
 1586,clock tower,17.44053,78.49793 
 1230,Bata,17.43563,78.49382 
 1589,Bible house,17.4309,78.49264 
 1169,boats club,17.42852,78.48835 
 1370,d b r mills,17.42187,78.48493 
 1682,Mini tankbund,17.40976,78.47594 
 894,Secretariat,17.40764,78.47116 
 895,AG office,17.40594,78.4673 
 342,ac guard,17.40279,78.45826 
 800,NMDC,17.39876,78.44937 
 761,SD Hospital,17.39798,78.44341 
 762,Mehdipatnam,17.39473,78.43841 
 2244,REthibowli,17.39506,78.43131 
 981,jyothi Nagar,17.38245,78.42978 
 2245,Ring road,17.37648,78.42952 
 3822,attapur x road,17.37023,78.42947 
 982,hyderguda x road ,17.36348,78.4283 
 983,upparpally x road,17.3551,78.42185 
 2247,Dairy Farm,17.3451,78.41619 
 4097,NPPTi,17.34252,78.41457 
 2452,Rajendranagar Depot,17.33504,78.41037 
 2458,budvel,17.33325,78.4097 
 3828,extension,17.32995,78.40941 
 2454,Rajendra Nagar,17.32183,70.40176 
 300,medical college,17.38299,78.48285 
 1439,cbs,17.37819,78.48219 
 1379,High Court,17.37023,78.47551 
 2471,kishanbagh,17.35921,78.44326 
 2469,9 number x road,17.35656,78.43831 
 2467,pahadi,17.35186,78.42896 
 2465,chinthalmet,17.35202,78.42169 
 2140,UPPAL x road,17.40095,78.56045 
 955,Saraswathi nagar,17.39449,78.55935 
 957,Nagole,17.37571,78.55788 
 1797,Snehapuri colony,17.36884,78.55743 
 958,Alkapuri,17.36388,78.55743 
 3795,rajiv gandhi Nagar,17.35967,78.55775 
 1798,Kamineni,17.35244,78.55563 
 959,LB NAgar,17.34578,78.55033 
 960,Sagar
"""

update_stops('c:\\manikanta chary\\my_app\\bus_ticketing_backend\\stops_id.csv', new_data)
