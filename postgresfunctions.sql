CREATE OR REPLACE FUNCTION add_restaurant(r_name text, _restaurantalias text)
    RETURNS text AS
    $$
    DECLARE _rowid integer := 0;
    BEGIN
        IF EXISTS(SELECT restaurant_ix FROM public.tblrestaurant WHERE restaurantname_s like '%'||r_name||'%' AND restaurantalias_s = _restaurantalias) = FALSE THEN
          INSERT INTO tblRestaurant(restaurantname_s, restaurantalias_s) values(r_name, _restaurantalias); SELECT currval('tblRestaurant_restaurant_ix_seq') INTO _rowid;
        ELSE RETURN 'RESTAURANT ALREADY EXISTS'; END IF; RETURN 'RESTAURANT ADDED ' || CAST(_rowid AS TEXT); END $$
LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION add_rest_address(_restaurantalias text, street1 text, street2 text, cityname  text, statename  text, stateabbr  text,
                                               zip  integer, country  text, countryabbr  text)
RETURNS text AS
    $$
    DECLARE
    _restid integer;
    _rowid integer := 0;
    BEGIN
    	SELECT restaurant_ix INTO _restid FROM tblrestaurant WHERE restaurantalias_s LIKE '%' || $1 || '%';
    	IF EXISTS (SELECT address_ix FROM tbladdress WHERE restaurant_ix = _restid) = FALSE THEN
            INSERT INTO public.tbladdress (restaurant_ix, street1_s, street2_s, cityname_s, statename_s, stateabbr_s, zip_i, country_s, countryabbr_s)
                VALUES (_restid, $2, $3, $4, $5, $6, $7, $8, $9);
            SELECT currval('tblAddress_address_ix_seq') into _rowid;
        END IF;
        RETURN 'ADDRESS ADDED ' || CAST(_rowid AS TEXT);
    END;
    $$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION add_rest_contact(_restaurantalias text, _contactname text, _phonemain text, _phonealt text, _fax text, _email text)
    RETURNS text AS
    $$
    DECLARE
        _restid integer; _rowid integer := 0;
    BEGIN
        SELECT restaurant_ix INTO _restid FROM tblrestaurant WHERE restaurantalias_s LIKE '%' || _restaurantalias || '%';
        IF _restid > 0 THEN
            INSERT INTO tblrestaurantcontact(staffname_s, phonemain_s, phonealt_s, fax_s, email_s, restaurant_ix) VALUES (_contactname, _phonemain, _phonealt, _fax, _email, _restid);
            SELECT currval('tblRestaurantcontact_restaurantcontact_ix_seq') INTO _rowid;
        END IF;
        RETURN 'CONTACT ADDED ' || CAST(_rowid AS TEXT);
    END
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_rest_with_info(_restname text, _restaurantalias text, _restcontactname text, _restphonemain text, _restphonealt text,
                                             _restfax text, _restemail text, _reststreet1 text, _reststreet2 text, _restcity text, _reststate text,
                                              _reststateabbr text, _restzip integer, _restcountry text, _restcountryabbr text)
	RETURNS integer AS
    $$
        DECLARE
            _restid integer;
            _restfound integer;
            _restadded integer := -1;
        BEGIN
            IF EXISTS (SELECT restaurant_ix FROM tblrestaurant WHERE restaurantname_s like '%' || _restname || '%' AND restaurantalias_s = $1) = FALSE THEN
                PERFORM add_restaurant(_restname, _restaurantalias);
                PERFORM add_rest_contact(_restaurantalias, _restcontactname, _restphonemain, _restphonealt, _restfax, _restemail);
                PERFORM add_rest_address(_restaurantalias, _reststreet1, _reststreet2, _restcity, _reststate, _reststateabbr, _restzip, _restcountry, _restcountryabbr);
                SELECT currval('tblrestaurant_restaurant_ix_seq') into _restadded;
        	END IF;
            RETURN _restadded;
        END
    $$
LANGUAGE plpgsql;

SELECT add_rest_with_info('China Wall', 'CW', 'Ping Chen', '(402) 489-9993', '(402) 489-9994', '(402) 489-9995',' chinawall@email.com',
                          '8550 Andermatt Dr', 'Suite #2', 'Lincoln', 'Nebraska', 'NE', 68521, 'United States', 'USA');

CREATE OR REPLACE FUNCTION add_category(category_name text, _id integer)
	RETURNS integer AS
    $$
    	INSERT INTO public.tblCategory(categoryname_s, restaurant_ix) VALUES($1, $2)
        RETURNING category_ix;
	$$
LANGUAGE 'sql' VOLATILE;

select add_category('Poultry', 1) as categoryId;
select add_category('Beef', 1) as categoryId;
select add_category('Pork', 1) as categoryId;
select add_category('Seafood', 1) as categoryId;
select add_category('HouseSpecial', 1) as categoryId;
select add_category('LoMein', 1) as categoryId;
select add_category('ChowMein', 1) as categoryId;
select add_category('EggFooYoung', 1) as categoryId;
select add_category('MeiFun', 1) as categoryId;
select add_category('FriedRice', 1) as categoryId;
select add_category('LowFatPlatter', 1) as categoryId;
select add_category('KidsMeals', 1) as categoryId;
select add_category('Appetizer', 1) as categoryId;
select add_category('Soup', 1) as categoryId;

insert into public.tblIngredientType(ingredienttypename_s) values('Meat');
insert into public.tblIngredientType(ingredienttypename_s) values('Sauce');
insert into public.tblIngredientType(ingredienttypename_s) values('Vegetable');
insert into public.tblIngredientType(ingredienttypename_s) values('Spice');
insert into public.tblIngredientType(ingredienttypename_s) values('Beans & Nuts');
insert into public.tblIngredientType(ingredienttypename_s) values('Other');


  CREATE OR REPLACE FUNCTION add_ingredient(ingredient_name text, ingredienttype_name text)
  	RETURNS integer AS
      $$
      DECLARE _idfound integer:= 0; _typeid integer:= 0;
      BEGIN
          IF EXISTS(SELECT ingredient_ix from tblingredient where ingredientname_s like '%' || ingredient_name || '%') = FALSE THEN
              SELECT ingredienttype_ix INTO _typeid from tblingredienttype WHERE ingredienttypename_s like '%' || ingredienttype_name || '%';
              IF _typeid >= 0 THEN
              	INSERT INTO tblingredient(ingredientname_s, ingredienttype_ix) VALUES(ingredient_name, _typeid);
          		SELECT currval('tblingredient_ingredient_ix_seq') into _idfound;
              ELSE
              	RETURN _typeid;
              END IF;
           END IF;
           RETURN _idfound;
      END
      $$
  LANGUAGE 'plpgsql' VOLATILE;

  SELECT add_ingredient('Chicken', 'Meat');
  SELECT add_ingredient('Beef', 'Meat');
  SELECT add_ingredient('Pork', 'Meat');
  SELECT add_ingredient('Shrimp', 'Meat');
  SELECT add_ingredient('Crab Meat', 'Meat');
  SELECT add_ingredient('Egg', 'Meat');
  SELECT add_ingredient('Fish', 'Meat');
  SELECT add_ingredient('Duck', 'Meat');
  SELECT add_ingredient('Bean Sprout', 'Vegetable');
  SELECT add_ingredient('Celery', 'Vegetable');
  SELECT add_ingredient('Carrot', 'Vegetable');
  SELECT add_ingredient('Corn', 'Vegetable');
  SELECT add_ingredient('Brocoli', 'Vegetable');
  SELECT add_ingredient('Cauliflower', 'Vegetable');
  SELECT add_ingredient('Green Pepper', 'Vegetable');
  SELECT add_ingredient('Red Pepper', 'Vegetable');
  SELECT add_ingredient('Bamboo Shoot', 'Vegetable');
  SELECT add_ingredient('Water Chesnut', 'Vegetable');
  SELECT add_ingredient('Snow Peas', 'Vegetable');
  SELECT add_ingredient('Bok Choy', 'Vegetable');
  SELECT add_ingredient('Mushroom', 'Vegetable');
  SELECT add_ingredient('Long Bean', 'Vegetable');
  SELECT add_ingredient('Cabbage', 'Vegetable');
  SELECT add_ingredient('Onion', 'Vegetable');
  SELECT add_ingredient('Scallion', 'Vegetable');
  SELECT add_ingredient('Garlic', 'Vegetable');
  SELECT add_ingredient('Ginger', 'Vegetable');
  SELECT add_ingredient('Tofu', 'Vegetable');
  SELECT add_ingredient('Bean Curd', 'Vegetable');
  SELECT add_ingredient('Pineapple', 'Vegetable');
  SELECT add_ingredient('Chili Sauce', 'Sauce');
  SELECT add_ingredient('Hot Mustard', 'Sauce');
  SELECT add_ingredient('Dumpling Sauce', 'Sauce');
  SELECT add_ingredient('Sweet & Sour', 'Sauce');
  SELECT add_ingredient('Soy Sauce', 'Sauce');
  SELECT add_ingredient('Brown Sauce', 'Sauce');
  SELECT add_ingredient('Orange Sauce', 'Sauce');
  SELECT add_ingredient('Garlic Sauce', 'Sauce');
  SELECT add_ingredient('Coconut Sauce', 'Sauce');
  SELECT add_ingredient('Sesame Sauce', 'Sauce');
  SELECT add_ingredient('Mongolian Sauce', 'Sauce');
  SELECT add_ingredient('White Sauce', 'Sauce');
  SELECT add_ingredient('Hunan Sauce', 'Sauce');
  SELECT add_ingredient('Szechuan Sauce', 'Sauce');
  SELECT add_ingredient('P.B. Sauce', 'Sauce');
  SELECT add_ingredient('General Tso''s Sauce', 'Sauce');
  SELECT add_ingredient('Steam Sauce', 'Sauce');
  SELECT add_ingredient('Salt', 'Spice');
  SELECT add_ingredient('Sugar', 'Spice');
  SELECT add_ingredient('MSG', 'Spice');
  SELECT add_ingredient('Peanut', 'Bean');
  SELECT add_ingredient('Almond', 'Bean');
  SELECT add_ingredient('Cashshew', 'Bean');
  SELECT add_ingredient('Sesame Seeds', 'Other');
  SELECT add_ingredient('Noodle', 'Other');
  SELECT add_ingredient('Chow Mein Noodle', 'Other');
  SELECT add_ingredient('Cream Cheese', 'Other');

-- truncate table public.ingredient restart identity;
-- truncate public.restaurant cascade;


SELECT add_rest_with_info('China Inn', 'CI', 'Hao Zhuo', '(402) 438-3949', '(402) 475-0032', '(402) 439-2354', 'chinainn@email.com',
                          '8383 Cornhusker Hwy #8', 'Lincoln', 'Nebraska', 'NE', 68526, 'United States', 'USA');

SELECT add_rest_with_info('Golden Wok', 'GW', 'Lin Wu', '(402) 420-9204', '(402) 383-2341', '(402) 234-5555', 'goldenwok@email.com',
                          '1050 N 27th', 'Lincoln', 'Nebraska', 'NE', 68521, 'United States', 'USA');

CREATE OR REPLACE FUNCTION add_sharedhour(_opentime time, _closetime time, _dayofweek text)
	RETURNS text AS
    $$
    DECLARE _id_added integer := 0;
    BEGIN
    	IF EXISTS (SELECT sharedhour_ix FROM tblsharedhour WHERE opentime_tm = _opentime and closetime_tm = _closetime
                  AND dayofweek_s = _dayofweek) = FALSE THEN
            INSERT INTO tblsharedhour(opentime_tm, closetime_tm, dayofweek_s) VALUES ($1, $2, $3);
            SELECT currval('tblsharedhour_sharedhour_ix_seq') into _id_added;
        ELSE RETURN 'TIME ALREADY EXISTS. ';
        END IF;
        RETURN cast(_id_added as text);
    END
    $$
LANGUAGE 'plpgsql' VOLATILE;

SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Monday') as _added_id;
SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Tuesday') as _added_id;
SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Wednesday') as _added_id;
SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Thursday') as _added_id;
SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Friday') as _added_id;
SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Saturday') as _added_id;
SELECT add_sharedhour('10:30 AM', '10:30 PM', 'Sunday') as _added_id;


CREATE OR REPLACE FUNCTION add_restauranthour(_restaurantalias text, _sharedhourid integer)
    RETURNS text AS
    $$
        DECLARE _restid integer := 0; _rowid integer := 0;
        BEGIN
            SELECT restaurant_ix INTO _restid FROM tblrestaurant WHERE restaurantalias_s LIKE '%' || $1 || '%';
            IF _restid > 0 THEN
                INSERT INTO tblrestauranthour(restaurant_ix, sharedhour_ix) VALUES(_restid, _sharedhourid);
                --SELECT currval('tblrestauranthour_restauranthour_ix_seq') INTO _rowid;
            ELSE
                RETURN 'UNABLE TO FIND RESTAURANT BY ALIAS. ';
            END IF;

            RETURN 'ROW INSERTED: ' || CAST(_rowid AS TEXT);
        END
    $$
LANGUAGE 'plpgsql' VOLATILE;

SELECT add_restauranthour('CW', 1);
SELECT add_restauranthour('CW', 2);
SELECT add_restauranthour('CW', 3);
SELECT add_restauranthour('CW', 4);
SELECT add_restauranthour('CW', 5);
SELECT add_restauranthour('CW', 6);
SELECT add_restauranthour('CW', 7);

DROP FUNCTION add_dishingredients(text,integer[]);

CREATE OR REPLACE FUNCTION add_dishingredients(_dishname text, _ingredientidlist integer[], _restaurantalias text)
	RETURNS text AS
    $$
    DECLARE _idfound integer := -1; _restid integer := 0; _rowid integer := -1; _dishid integer := 0; _ingid integer:= 0;

    BEGIN
    	SELECT restaurant_ix INTO _restid FROM tblrestaurant WHERE restaurantalias_s LIKE '%' || _restaurantalias || '%';
        IF _restid > 0 THEN
        	IF EXISTS(SELECT di.dish_ix FROM tbldishingredient di Join tbldish d on di.dish_ix = d.dish_ix JOIN tblrestaurant r
                      ON d.restaurant_ix = r.restaurant_ix WHERE d.dishname_s LIKE '%' || _dishname || '%' AND r.restaurant_ix = _restid) = FALSE THEN
                Select dish_ix INTO _dishid FROM tbldish WHERE dishname_s LIKE '%' || _dishname || '%';

                FOREACH _ingid in ARRAY _ingredientidlist
                LOOP
                    INSERT INTO tbldishingredient(dish_ix, ingredient_ix) VALUES(_dishid, _ingid);
                END LOOP;
                --SELECT currval('tbldishingredient_dishingredient_ix_seq') INTO _rowid;
            ELSE
            	RETURN 'DISHINGREDIENT ALREADY EXISTS FOR THIS RESTAURANT';
            END IF;
        ELSE
            RETURN 'RESTAURANT ID WAS NOT FOUND';
        END IF;
        RETURN 'ROW INSERTED ' || CAST(_rowid AS text);
    END
    $$
LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION add_dish(_restaurantalias text, _dishname text, _description text, _categoryname text, _pricebreakfast numeric, _pricelunch numeric,
                                        _pricecombo numeric, _pricedinner numeric, _isbreakfast boolean, _islunch boolean, _iscombo boolean, _isspicy boolean)
	RETURNS text AS
    $$
    DECLARE _restid integer := 0; _categoryid integer := 0; _rowid integer := -1; _catname varchar; _catid integer[];
    BEGIN
        SELECT restaurant_ix INTO _restid FROM tblrestaurant WHERE restaurantalias_s = $1;

        --FOREACH _catname in ARRAY _categoryname
        --LOOP
        	SELECT category_ix INTO _categoryid FROM tblcategory WHERE categoryname_s LIKE '%'||_categoryname||'%';
        --    _catid := _catid || _categoryid;
        --END LOOP;

        -- IF _restid > 0 AND array_length(_catid,1) > 0 THEN
        IF _restid > 0 AND _categoryid > 0 THEN
            IF EXISTS(SELECT dish_ix FROM tbldish WHERE restaurant_ix = _restid AND dishname_s like '%' || _dishname || '%') = FALSE THEN
                       --      RETURN 'here' || Cast(array_length(_iscombo as text);
                INSERT INTO tbldish(dishname_s, description_s, restaurant_ix, category_ix, pricebreakfast_dbl, pricelunch_dbl, pricecombo_dbl, pricedinner_dbl, isbreakfast_b, islunch_b, isspicy_b, iscombo_b)
                VALUES(_dishname, _description, _restid, _categoryid, _pricebreakfast, _pricelunch, _pricecombo, _pricedinner, _isbreakfast, _islunch, _isspicy, _iscombo);
                 SELECT currval('tbldish_dish_ix_seq') INTO _rowid;
                 --RETURN 'here' || Cast(array_length(_catid, 1) as text);
            END IF;
        ELSE
            IF _restid <= 0 OR _restid IS NULL THEN
            	RETURN 'DISH ALREADY EXISTS.';

            ELSE
                RETURN 'SOMETHING WENT WRONG WHILE ADDING DISH. ' || _categoryname;
            END IF;
        END IF;
       	 RETURN 'DISH ADDED ' || CAST(_rowid AS TEXT);
     END
    $$
LANGUAGE 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION add_dish_and_dishingredients(_restaurantalias text, _dishname text, _description text,
                            _categoryname text, _pricebreakfast numeric, _pricelunch numeric, _pricecombo numeric, _pricedinner numeric,
                            _isbreakfast boolean, _islunch boolean, _iscombo boolean, _isspicy boolean, _dishingredientlist varchar[])
    RETURNS text AS
    $$
        DECLARE _adddish text:= 'none'; _adddishingredient text := 'none'; _intarray integer[]; _indgname varchar; _id integer := 0; _dishid integer := 0;
        BEGIN
            FOREACH _indgname IN ARRAY _dishingredientlist
            LOOP
                SELECT ingredient_ix INTO _id FROM tblingredient WHERE ingredientname_s LIKE '%' || _indgname || '%';
                _intarray := _intarray || _id;
            END LOOP;

            SELECT add_dish(_restaurantalias, _dishname, _description, _categoryname, _pricebreakfast, _pricelunch,
                            _pricecombo, _pricedinner, _isbreakfast, _islunch, _iscombo, _isspicy) INTO _adddish;
            --SELECT id INTO _dishId FROM public.dish where dishname like '%' || _dishname || '%';
            SELECT add_dishingredients(_dishname, _intarray, _restaurantalias) INTO _adddishingredient;
        RETURN _adddish || '--' || _adddishingredient;
        END;
    $$
LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION add_dish_image()
  RETURNS void AS
  $$
    DECLARE _dishname text:= ''; _dish_ix integer:= 0;
    BEGIN
      FOREACH dish_ix IN
        select replace(replace(regexp_replace(dishname_s, '[''''|.|\\)]', ''), '(', ''), ' ', '_') as _dishname, dish_ix from tbldish;
      LOOP
        FOREACH imagesize IN
          SELECT dishimagesize_ix FROM tblDishImageSize;
        LOOP
          INSERT INTO tblDishImage(imageposition_i, imagename_s, createuser_s, updateuser_s, createdateutc_dt, updatedateutc_dt, dish_ix, dishimagesize_ix)
            VALUES(1, _dishname, 'NETT',, CURRENT_TIMESTAMP,, dish_ix, dishimagesize_ix)
        END LOOP;
      END LOOP;
    END:
  $$
LANGUAGE 'plpgsql' VOLATILE;


SELECT add_dish_and_dishingredients('CW', 'Chicken and Broccoli', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chicken, Broc, Brown S}');SELECT add_dish_and_dishingredients('CW', 'General Tso''s Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Chicken, Broc, Red, Scall, Gen}');
SELECT add_dish_and_dishingredients('CW', 'Kung Pao Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Car, Green, Red, Water, Cel}');
SELECT add_dish_and_dishingredients('CW', 'Hunan Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Snow, Water, Car, Green, Red, Broc, Cel, Hunan S}');
SELECT add_dish_and_dishingredients('CW', 'Chicken w. Garlic Sauce', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Snow, Chicken, Water, Car, Green, Red, Broc, Cel, Hunan S, Garlic S}');
SELECT add_dish_and_dishingredients('CW', 'Sesame Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chick, Broc, Red, Scall, Sesame S}');
SELECT add_dish_and_dishingredients('CW', 'Orange Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Chick, Broc, Red, Scall, Orange S}');
SELECT add_dish_and_dishingredients('CW', 'Sweet ''n Sour Chicken', 'N/A', 'Poultry', 0.00, 7.95, 5.95, 9.95, False, True, True, False, '{Chick, Sweet}');
SELECT add_dish_and_dishingredients('CW', 'Cashew Chicken', 'N/A', 'Poultry', 0.00,5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Chick, Cash}');
SELECT add_dish_and_dishingredients('CW', 'Almond Chicken', 'N/A', 'Poultry', 0.00,  5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Chick, Almond}');
SELECT add_dish_and_dishingredients('CW', 'Chicken w. Snow Peas', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Snow, Water, Car, Chicken, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Chicken w. Chinese Vegetables', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Snow, Water, Car, Chicken, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Moo Goo Gai Pan', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Snow, Water, Car, Green, Red, Chicken, Broc, Cel, Hunan S, White S}');
SELECT add_dish_and_dishingredients('CW', 'Peanut Butter Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{P.B., Car, Onion, Scal, Chicken}');
SELECT add_dish_and_dishingredients('CW', 'Szechuan Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, False, True, True, '{Snow, Water, Car, Green, Chicken, Red, Broc, Cel, Hunan S, Szechuan S}');
SELECT add_dish_and_dishingredients('CW', 'Mongolian Chicken', 'N/A', 'Poultry', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Chicken, Onion, Scal, Mongolian S}');

SELECT add_dish_and_dishingredients('CW', 'Beef and Broccoli', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Snow, Water, Car, Green, Red, Beef, Broc, Cel, Hunan S, Hunan S}');
SELECT add_dish_and_dishingredients('CW', 'Hunan Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Snow, Water, Car, Green, Red, Beef, Broc, Cel, Hunan S, Hunan S}');
SELECT add_dish_and_dishingredients('CW', 'General Tso''s Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Beef, Broc, Red, Scall, Gen}');
SELECT add_dish_and_dishingredients('CW', 'Kung Pao Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Beef, Car, Green, Red, Water, Cel}');
SELECT add_dish_and_dishingredients('CW', 'Beef w. Garlic Sauce', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Beef, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Garlic S}');
SELECT add_dish_and_dishingredients('CW', 'Sesame Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Beef, Broc, Red, Scall, Sesame Sauce, Sesame Seed}');
SELECT add_dish_and_dishingredients('CW', 'Orange Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Beef, Broc, Red, Scall, Orange Sauce}');
SELECT add_dish_and_dishingredients('CW', 'Cashew Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Beef, Cash}');
SELECT add_dish_and_dishingredients('CW', 'Almond Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Beef, Almond}');
SELECT add_dish_and_dishingredients('CW', 'Beef w. Snow Peas', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Beef, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Beef w. Chinese Vegetables', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Beef, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Pepper Steak w. Onion', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Beef, Green, Onion}');
SELECT add_dish_and_dishingredients('CW', 'Szechuan Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, False, True, True, '{Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Szechuan S}');
SELECT add_dish_and_dishingredients('CW', 'Mongolian Beef', 'N/A', 'Beef', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Beef, Onion, Scal, Red, Mongolian S}');

SELECT add_dish_and_dishingredients('CW', 'Pork and Broccoli', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Broc}');
SELECT add_dish_and_dishingredients('CW', 'General Tso''s Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Broc, Red, Scall, Gen}');
SELECT add_dish_and_dishingredients('CW', 'Kung Pao Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Car, Green, Red, Water, Cel}');
SELECT add_dish_and_dishingredients('CW', 'Hunan Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Snow, Water, Car, Green, Red, Pork, Broc, Cel, Hunan S, Hunan S}');
SELECT add_dish_and_dishingredients('CW', 'Pork w. Garlic Sauce', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Garlic S}');
SELECT add_dish_and_dishingredients('CW', 'Sesame Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Broc, Red, Scall, Sesame Sauce, Sesame Seed}');
SELECT add_dish_and_dishingredients('CW', 'Orange Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Broc, Red, Scall, Orange Sauce}');
SELECT add_dish_and_dishingredients('CW', 'Sweet ''n Sour Pork', 'N/A', 'Pork', 0.00, 7.95, 5.95, 9.95, False, True, True,False, '{Pork, Pine, Onion, Scal}');
SELECT add_dish_and_dishingredients('CW', 'Cashew Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Pork, Cash}');
SELECT add_dish_and_dishingredients('CW', 'Almond Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Pork, Almond}');
SELECT add_dish_and_dishingredients('CW', 'Pork w. Snow Peas', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Pork w. Chinese Vegetables', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Szechuan Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Szechuan S}');
SELECT add_dish_and_dishingredients('CW', 'Mongolian Pork', 'N/A', 'Pork', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Onion, Scal, Red, Mongolian S}');

SELECT add_dish_and_dishingredients('CW', 'Shrimp and Broccoli', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Broc}');
SELECT add_dish_and_dishingredients('CW', 'Kung Pao Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Shrimp, Car, Green, Red, Water, Cel}');
SELECT add_dish_and_dishingredients('CW', 'Hunan Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Snow, Water, Car, Green, Red, Shrimp, Broc, Cel, Hunan S, Hunan S}');
SELECT add_dish_and_dishingredients('CW', 'Shrimp w. Garlic Sauce', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Shrimp, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Garlic S}');
SELECT add_dish_and_dishingredients('CW', 'Sesame Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Broc, Red, Scall, Sesame Sauce, Sesame Seed}');
SELECT add_dish_and_dishingredients('CW', 'Sweet ''n Sour Shrimp', 'N/A', 'Seafood', 0.00, 7.95, 5.95, 9.95, False, True, True, False, '{Shrimp, Pine, Onion, Scal}');
SELECT add_dish_and_dishingredients('CW', 'Cashew Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Shrimp, Cash}');
SELECT add_dish_and_dishingredients('CW', 'Almond Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Car, Cel, Shrimp, Almond}');
SELECT add_dish_and_dishingredients('CW', 'Shrimp w. Snow Peas', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Shrimp w. Chinese Vegetables', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Brown S}');
SELECT add_dish_and_dishingredients('CW', 'Szechuan Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Shrimp, Snow, Water, Car, Green, Red, Broc, Cel, Hunan S, Szechuan S}');
SELECT add_dish_and_dishingredients('CW', 'Mongolian Shrimp', 'N/A', 'Seafood', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Shrimp, Onion, Scal, Red, Mongolian S}');

SELECT add_dish_and_dishingredients('CW', 'Chicken Lo Mein', 'N/A', 'LoMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chicken, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Beef Lo Mein', 'N/A', 'LoMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Beef, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Pork Lo Mein', 'N/A', 'LoMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'ShrimpLo Mein', 'N/A', 'LoMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'House Special Lo Mein', 'N/A', 'LoMein', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Chicken, Pork, Shrimp, Scal, Onion, Cab}');

SELECT add_dish_and_dishingredients('CW', 'Chicken Chow Mein', 'N/A', 'ChowMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chicken, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Beef Chow Mein', 'N/A', 'ChowMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Beef, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Pork Chow Mein', 'N/A', 'ChowMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Shrimp Chow Mein', 'N/A', 'ChowMein', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'House Special Chow Mein', 'N/A', 'ChowMein', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Chicken, Pork, Shrimp, Scal, Onion, Cab}');

SELECT add_dish_and_dishingredients('CW', 'Chicken Fried Rice', 'N/A', 'FriedRice', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chicken, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Beef Fried Rice', 'N/A', 'FriedRice', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Beef, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Pork Fried Rice', 'N/A', 'FriedRice', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Shrimp Fried Rice', 'N/A', 'FriedRice', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Shrimp, Scal, Onion, Cab}');
SELECT add_dish_and_dishingredients('CW', 'House Special Fried Rice', 'N/A', 'FriedRice', 0.00, 5.95, 7.95, 9.95, False, False, False, False, '{Chicken, Pork, Shrimp, Scal, Onion, Cab}');


-- SELECT add_dish_and_ingredient('CW', 'Chicken Mei Fun', 'N/A', 'MeiFun,Chicken', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'Beef Mei Fun', 'N/A', 'MeiFun,Beef', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'Pork Mei Fun', 'N/A', 'MeiFun,Pork', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'Shrimp Mei Fun', 'N/A', 'MeiFun,Shrimp', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'House Specal Mei Fun', 'N/A', 'MeiFun', 5.95, 7.95, 9.95, False, False, '{1,12}');

-- SELECT add_dish_and_ingredient('CW', 'Chicken Egg Foo Young', 'N/A', 'EggFooYoung,Chicken', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'Beef Egg Foo Young', 'N/A', 'EggFooYoung,Beef', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'Pork Egg Foo Young', 'N/A', 'EggFooYoung,Pork', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'Shrimp Egg Foo Young', 'N/A', 'EggFooYoung,Shrimp', 5.95, 7.95, 9.95, True, True, '{1,12}');
-- SELECT add_dish_and_ingredient('CW', 'House Egg Foo Young', 'N/A', 'EggFooYoung', 5.95, 7.95, 9.95, False, False, '{1,12}');

SELECT add_dish_and_dishingredients('CW', 'Egg Drop Soup', 'N/A', 'Soup', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Egg}');
SELECT add_dish_and_dishingredients('CW', 'Hot & Sour Soup', 'N/A', 'Soup', 0.00, 5.95, 7.95, 9.95, False, True, True, True, '{Pork, Tofu}');
SELECT add_dish_and_dishingredients('CW', 'Wonton Soup', 'N/A', 'Soup', 0.00, 6.95, 7.95, 9.95, False, True, True, False, '{Pork}');
SELECT add_dish_and_dishingredients('CW', 'Chicken Noodle Soup', 'N/A', 'Soup', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Noodle, Carrot, Scal}');
SELECT add_dish_and_dishingredients('CW', 'Vegetable Soup', 'N/A', 'Soup', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Cab, Snow, Scal, Broc, Bok}');
SELECT add_dish_and_dishingredients('CW', 'House Special Soup', 'N/A', 'Soup', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chicken, Pork, Shrimp, Cab, Snow, Scal, Broc, Bok}');

SELECT add_dish_and_dishingredients('CW', 'Egg Roll', 'N/A', 'Appetizer', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Spring Egg Roll', 'N/A', 'Appetizer', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork, Cab}');
SELECT add_dish_and_dishingredients('CW', 'Fried Wonton or Szechuan Wonton', 'N/A', 'Appetizer', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork}');
SELECT add_dish_and_dishingredients('CW', 'Dumplings (Fried or Steam)', 'N/A', 'Appetizer', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Pork}');
SELECT add_dish_and_dishingredients('CW', 'Chicken Fingers', 'N/A', 'Appetizer', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Chicken}');
SELECT add_dish_and_dishingredients('CW', 'Crab Rangoon', 'N/A', 'Appetizer', 0.00, 5.95, 7.95, 9.95, False, True, True, False, '{Cream, Scallion, Crab}');


Insert into tblDishImageSize(height_i, width_i, sizename_s) values(300, 300, 'LRG');
Insert into tblDishImageSize(height_i, width_i, sizename_s) values(200, 200, 'MED');
Insert into tblDishImageSize(height_i, width_i, sizename_s) values(100, 100, 'SML');


CREATE OR REPLACE FUNCTION add_dish_image()
  RETURNS void AS
  $$
    DECLARE _dishname text:= ''; _dish_ix integer:= 0; temprow record; imagesize record; _fulldishname text:= '';
    BEGIN
      delete from tbldishimage where dishimage_ix > 0;
      FOR temprow IN
        select replace(replace(regexp_replace(dishname_s, '[''''|.|\\)]', ''), '(', ''), ' ', '_') as _dishname, dish_ix from tbldish
      LOOP

      FOR imagesize IN
          SELECT * FROM tblDishImageSize
        LOOP
        	_fulldishname = temprow._dishname || '_' || imagesize.sizename_s;
          INSERT INTO tblDishImage(imageposition_i, imagename_s, createuser_s, updateuser_s, createdateutc_dt, updatedateutc_dt, dish_ix, dishimagesize_ix)
            VALUES(1, _fulldishname, 'NETT',NULL, CURRENT_TIMESTAMP, NULL, temprow.dish_ix, imagesize.dishimagesize_ix);
        END LOOP;
      END LOOP;
    END;
  $$
LANGUAGE 'plpgsql' VOLATILE;

select add_dish_image();
