drop table if exists tblDishImage;
drop table if exists tblDishImageSize;
drop table if exists tblRestaurantContact;
drop table if exists tblAddress;
drop table if exists tblRestaurantHour;
drop table if exists tblSharedhour;
drop table if exists tblDishingredient;
drop table if exists tblDish;
drop table if exists tblIngredient;
drop table if exists tblIngredienttype;
drop table if exists tblCategory;
drop table if exists tblRestaurant;

CREATE TABLE tblRestaurant (
    restaurant_ix SERIAL PRIMARY KEY,
    restaurantname_s text not null,
    restaurantalias_s text not null
);

CREATE TABLE tblSharedHour (
    sharedhour_ix SERIAL PRIMARY KEY,
    opentime_tm time not null,
    closetime_tm time not null,
    dayofweek_s text not null  /* M,T,W,TH,F,SA,S*/
);

CREATE TABLE tblRestaurantHour (
    restaurant_ix integer REFERENCES tblRestaurant(restaurant_ix) not null,
    sharedhour_ix integer not null
);

CREATE TABLE tblAddress (
  	address_ix SERIAL PRIMARY KEY,
  	street1_s text not null,
  	street2_s text,
    cityName_s text not null,
    stateName_s text not null,
    stateAbbr_s text not null,
    zip_i integer not null,
    country_s text not null,
    countryAbbr_s text not null,
    restaurant_ix integer REFERENCES tblRestaurant(restaurant_ix) not null
);

CREATE TABLE tblRestaurantContact (
	  restaurantcontact_ix SERIAL PRIMARY KEY,
    staffname_s text not null,
    phonemain_s text not null,
    phonealt_s text,
    fax_s text,
    email_s text,
    restaurant_ix integer REFERENCES tblRestaurant(restaurant_ix) not null
);

CREATE TABLE tblCategory (
    category_ix SERIAL PRIMARY KEY,
    categoryname_s text not null,
    restaurant_ix integer REFERENCES tblRestaurant(restaurant_ix) not null

);

CREATE TABLE tblDish (
    dish_ix SERIAL PRIMARY KEY,
  	dishname_s text not null,
    description_s text not null,
    category_ix integer not null,
    pricebreakfast_dbl numeric(4,2) not null default 0.00,
    pricelunch_dbl numeric(4,2) not null default 0.00,
    pricecombo_dbl numeric(4,2) not null default 0.00,
    pricedinner_dbl numeric(4,2) not null default 0.00,
    isbreakfast_b boolean not null default False,
    islunch_b boolean not null default False,
    iscombo_b boolean not null default False,
    isspicy_b boolean not null default False,
    isfeatured_b boolean not null default FALSE,
    restaurant_ix integer REFERENCES tblRestaurant(restaurant_ix) not null
);

CREATE TABLE tblIngredienttype (
    ingredienttype_ix SERIAL PRIMARY KEY,
    ingredienttypename_s text UNIQUE not null
);

CREATE TABLE tblIngredient (
    ingredient_ix SERIAL PRIMARY KEY,
    ingredientname_s text not null,
    ingredienttype_ix integer REFERENCES tblIngredientType(ingredienttype_ix) not null
);


CREATE TABLE tblDishIngredient (
  	dish_ix integer not null,
    ingredient_ix integer not null references tblIngredient(ingredient_ix)
);

CREATE TABLE tblDishImageSize (
    dishimagesize_ix SERIAL PRIMARY KEY,
    height_i integer not null,
    width_i integer not null,
    sizename_s text not null --(ex: S for small, M for Medium,...)
);

CREATE TABLE tblDishImage (
    dishimage_ix SERIAL PRIMARY KEY,
    imageposition_i integer not null,
    imagelocation_s text not null,
    dish_ix integer REFERENCES tblDish(dish_ix) not null,
    dishimagesize_ix integer REFERENCES tblDishImageSize(dishimagesize_ix) not null,
    createuser_s text,
    updateuser_s text,
    createdateutc_dt timestamp,
    updatedateutc_dt timestamp
);
