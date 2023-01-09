SAS Course part 2 out of 4
================
Douwe Horsthuis
2023-01-09

# Data step

## Order

The order in the data step is important for some specific statements,
but not all. During the data phase there are 2 steps, **COMPILATION**
and **EXECUTION**. In the compilation step SAS establish data attributes
and rules for execution. In the execution step SAS read, manipulate, and
write data.

### Compilation

SAS does 4 things during the compilation step:

1.  Check for syntax errors.

2.  Create the program data vector (PDV\*).

3.  Establishes rules for processing data in the PDV.

4.  Create descriptor portion of the output table.

##### PDV

\*The PDV or program data vector includes each column that you’ve
referenced in the DATA step and its attributes, including the column
name,type and length. It looks like a one-row table because the PDV is
used in the execution phase to hold and manipulate one row of data at a
time. It’s important to know that SAS uses the first reference of a
column to set these attributes, that is why for example length staments
need to be at the start of the data step. Another important thing to
note is that a drop statement doesn’t drop a column instantly, it only
marks the column as needing to be dropped, so only after the statement
is completed will the column be dropped.

The following happen in the compilation stage, or are
“compile-time-statements”

-   Where
-   Retain

### Execution

SAS does 5 things in the execution phase:

1.  Initialize PDV.

2.  Read a row from the input table into the PDV.

3.  Sequentially process statements and update values in the PDV.

4.  At end of the step, write the contents of the PDV to the output
    table.

5.  Return to the top of the DATA step

# Debugging

## Sas Enterprize debugger

When you use the software (enterprise) you can use the debugger. This
will show you line by line if you run into errors and how your data
behaves row by row. **You can even change values during a loop to see
how it impacts your code.**

### Watchpoint

You can add a “watchpoint” by clicking on the checkboxes in the
debugger. If you do this, the debugger will run until that value
changes.

## Online platform

### Putlog

If you use the online platform you can use statements such as `putlog`
to get similar information. For example
`putlog "PDV After SET Statement";` Will give you the PDV after the SET
statement, if you follow this with `putlog_all_;` SAS will print it for
you. This works especially well with the `obs=n` statement int the set
step so you don’t run you whole table, because you will get a line for
each row you run.

## Implicit and explicit outputs

At the end of your data step SAS generates a Implicit output. This is
how it is run normally. However, you can choose a specific moment to
generate an output or *explicit output.* You do this by adding `output;`
to the script. After output has been reached, the data step creates the
output and starts from the start. After using `output;` in the datastep,
once or multiple times, the place where the *implicit output* would
happen will be skipped. If you still need an output at the end, you need
to also add `output;` there. If you add the name out the output table,
your output will only be written there. So `output sales_low;` add
whatever your output is to the sales_low table.

### Dropping columns

You can drop columns with the `drop column-name` line. But if you want
to keep different different columns because you are outputting data to
different tables you can specify this. The following code only drops the
column `Returns` for one and `Inventory` for the other:

``` sas
data sales_high(drop=Returns) sales_low(drop=Inventory);  
  set sashelp.shoes;
  ... *whatever you are looking at  
  drop Inventory Returns *not always needed;  
run;
```

If you use a `drop` or `keep` statement in the `set` statement, that
column will be dropped before it can be used for a calculation. If you
use the `drop` or `keep` statement later it can still be used for
calculations, but won’t end up in your output table.

## Accumulating column

An accumulating column will store a running total. For this to work, you
have to make sure not to start with a missing value and that it doesn’t
reinitialize again with the beginning potentially missing value. You can
do this using the `RETAIN column-name <initial-value>;` statement. This
is a compile time statement, that sets a rule for one or more columns to
keep their value. To create the accumulating column you can, after
`RETAIN`, use `NewColumn=NewColumn+OldColumn;` But it’s better to use
`NewColumn=sum(NewColumn,OldColumn);`. This is because it will ignore
missing values in the OldColumn.

See this example:

``` sas
proc sort data=sashelp.shoes out=shoes_sorted;
    by Region Product;
run;

data profitsummary;
    set shoes_sorted;
    Profit=Sales-Returns;
    by Region Product;
    Retain TotalProfit 0;
    format TotalProfit dollar13.;

    if first.Region then
        TotalProfit=0;

    if first.Product then
        TotalProfit=0;
    TotalProfit=sum(TotalProfit, Profit);
run;
```

# Functions

Functions changes the stored values, whereas the format affects only the
displayed values.

SAS uses a lot of functions. Here are some useful ones:

## Calculation

-   Ways to get more use out of simple functions:
    -   `mean(quiz1,quiz2, quiz3);` gives you the average

    -   `mean(of quiz1-quiz3);` give you the average (as long as there
        is a sequential number.

    -   `mean(of Q);` gives you the average, as long as columns start
        with the specified character.
-   Unfamiliar functions to me:
    -   `INTCK('interval',start-date,end-date,<'method'>);` This can
        calculate date intervals (year, month, week, weekday)

        -   The discrete calculation will use calendar weeks (so maybe
            after 2 days the week is ending) as measurement. This is
            standard.

        -   The continues calculation will just take 7 days from your
            start date and call that a week. In this case the ‘method’
            is ‘C’.

    -   `INTNX('interval', start, increment <,'alignment'>)` This can
        adjust a date by a set interval. For example if you have a Sales
        date, and you want to fin a billing date.

        -   if the **increment** is 0, your date will be set to the
            first of that increment. So `intnx('month,Date,0)` will use
            the date from the Date column, and shift it to the first of
            that month. If you instead set the increment to 2, you go 2
            months into the future.

        -   if you don’t use \<**‘alignment’**\> the default alignment
            is the start of your selected time period. If you would add
            ‘end’ it would instead give you the end of your selected
            time period. possible: end, middle, same

    -   `ANYDTDTEw.` which stands for any date format. It takes longer
        to calculate, but allows for dates that are not all written the
        same way to be turned into the same type of values. if the date
        is ambigues (1/12/2022, which can be januari 12th or first of
        december, it uses the clock of your computer. This means it
        won’t be aware that people in the US don’t know how to write
        dates in a sensible way. You can adress this by using the
        `DATESTYLE=MDY or DMY` option.

## Formatting

-   using `--` this will allow you to put a start and end column. For
    example `format Quiz1--AvgQuiz 3.1;` formats all columns from Quiz1
    to AvgQuiz.
-   using `_NUMERIC_` will format all the numeric columns.
-   using `_CHARACTER_` will format all the character columns.
-   using `_ALL_` will format all columns.

### Creating your own formatting

You can also create your own custom formats. You can do this using the
`PROC format` statement. See this example:

``` sas
PROC FORMAT;
  VALUE format-name value-or-range-1 = 'formatted-value';
RUN;
```

-   format-name = the name for your format

    -   up to 32 char,

    -   char format -\$ followed by letter or underscore

    -   Numeric format - begins with letter or underscore

    -   cannot end in number or matching existing SAS format

    -   NO period after the format-name

        -   When using a range of numbers

            -   using 10-\<15 will exclude 15 but include everything
                between 10-15 including 10. 1

            -   0\<-15 would do the same excluding 10 but including 15.

            -   You can also use key-words such as low or high.

            -   Other is important because it will include all values
                that do not match the pre-defined values.

-   value-or-range-1= value or range of values that you want to convert
    to formatted values

    -   Char values need quotes

    -   Numeric values do NOT need quotes

-   ‘formatted-value’ The formatted values that you want the values on
    the left side to become.

    -   in quotation marks

-   You can use multiple formats in one statment

See this example, where C will become complete and I will become
Incomplete:

``` sas
PROC FORMAT;
  value $regfmt 'C' ='Complete'
                'I' ='Incomplete';
RUN;
```

In this first one, it can be applied to each column in the table. In the
next example it will be specified:

``` sas
PROC PRINT data=pg2.class_birthday;
  format Registration $regfmt.;
RUN;
```

**In when applying the format you need to add the period after the
format.**

Another example:

``` sas
PROC FORMAT;
  value stdate low - '31DEC1999'd = '1999 and before'
                    '01JAN2000'd - '31DEC2009'd = '2000 to 2009'
                    '01JAN2010'd -high = 2010 and later'
                    .= 'Not Supplied';
  Value $region 'NA' ='Atlantic'
                'WP', 'EP', 'SP'='Pacific' 
                'NI', 'SI' = 'Indian'
                ' ' ='Missing'
                other='Unknown';
RUN;
```

### Use a table to create a custom format

It can be tedious to create a format if you have to add a lot of
information. You could use a table for this. The table needs to have at
least 3 columns. The first on needs to have the format name. This might
need a dollar sign if it’s character based. A start and an Label column.
If you have a range, you also need an end column.

if you use the following code you can turn table 1 into table 2.

| Sub_Basin | SubBasin_Name     |
|-----------|-------------------|
| AS        | Arabian Sea       |
| BB        | Bay of bengal     |
| EA        | Eastern Australia |

table 1

| FormatName | Start | Label             |
|------------|-------|-------------------|
| \$SBformat | AS    | Arabian Sea       |
| \$SBformat | BB    | Bay of Bengal     |
| \$SBformat | EA    | Eastern Australia |

table 2 (ready for formatting)

``` sas
data work.sbdata;
  retain FMTNAM '$sbfmt';
  set pg2.sorm_subbasincode(rename=(sub_Basin=Start SubBasin_Name=Label));
  Keep Start Label FMTNAME;
Run;
```

The format can now be created using the `cntlin` statement like this:

``` sas
PROC FORMAT cntlin=work.sbdata;
run;
```

### Storing Custom Formats

SAS will store custom formats by default in work.formats or
library.formats. But you can choose to store them somewhere else. If you
add `library=NameOfLibrary` to the `proc format` line you store your new
custom format in a specific library. You can also choose to add
`proc format library=NameOfLibrary.format;`

### Finding Custom Formats

SAS will store custom formats by default in work.formats or
library.formats. But if you store them somewhere else you can use the
`option fmtsearch` statement to search. For example
`option fmtsearch=(pg2.myfmts sashelp);` will search in the myftms
folder of pg2 and in the sashelp folder.

## Character functions

-   `upcase(char)` all uppercase

-   `PROPCASE(char,<delimiters>)` One Capital And The Rest Small. Not
    defining the delimiter means all will be used (.,!-? etc.) this can
    be a problem.

-   `SUBSTR(char,position <,length>)` use the rest of the
    string(variable,number of letter, optional: length of substring).

-   `COMPBL(string)` Returns a character string with all multiple blanks
    in the source string converted to single blanks.

-   `COMPRESS(string <, characters>)` Returns a character string with
    specified characters removed from the source string. This can be
    multiple characters together in a row, order is not relevant.

-   `STRIP(string)` Returns a character string with leading and trailing
    blanks removed.

-   `SCAN(string,n<,'delimiter'>)` String=variable name, n= number of
    word to extract, delimiter= what separates the words. Not defining
    the delimiter means all will be used (.,!-? etc.) this can be a
    problem.

-   `FIND(string, substring <,'modifiers'>)` string=variable name,
    substring= the substring you are looking for, modifiers= i-case
    insensitive T-trim leading and trailing blanks from string and
    substring. The outcome is a number of where the substring starts, if
    not found, then it is 0.

-   `LENGTH(string)` Returns the length of a non-blank character string,
    excluding trailing blanks; returns 1 for a completely blank string.

-   `ANYDIGIT(string)` Returns the first position at which a digit is
    found in the string.

-   `ANYALPHA(string)` Returns the first position at which an alpha
    character is found in the string.

-   `ANYPUNCT (string)` Returns the first position at which punctuation
    character is found in the string.

-   `TRANWRD(source, target, replacement)` source= column name,
    target=string to find, replacement=replacement string.

-   `CAT(string1, … stringn)` Concatenates strings together, does not
    remove leading or trailing blanks.

-   `CATS (string1, … stringn)` Concatenates strings together, removes
    leading or trailing blanks from each string. You can add delimiters
    where you want them.

-   `CATX ('delimiter', string1, … stringn)` Concatenates strings
    together, removes leading or trailing blanks from each string, and
    inserts the delimiter between each string.

## Call routine

A call routine functions similar to a function, but instead of returning
a value, it alters column values or preforms other system functions

## Converting column type

SAS will try to attempt to do this for you. It seems like it always will
need a double check. It cannot deal with commas, but can deal with
standard numeric values (e.g. 1 or 7643.12). SAS can also transform
numbers into characters. While this all can be done automatically, if
you need more control, you can also do it manually.

`INPUT(source,format)` characters to numeric, where format dictates how
to **read** the character string. Example: `Date2=input(Date,date9.);`
This creates Date2 using the characters from Date reading it using the
date9. format (which allows it to turn it into numbers). Pay extra
attention when forcing decimal points.

`PUT(source,format)` numeric to characters, where format dictates how to
**write** the character string. Example: `DAY=put(DATE,downame3.);` Here
it turns the numbers of date into a day name of 3 characters .

### Change the column type of an existing column

You cannot do this after the PDV is created. That is why you have to
make a few changes. In your set statement you have to rename the
existing column to a name that won’t exist in the output. After that you
can create a statement that sets the correct type (using `INPUT` or
`PUT`).

Example for `INPUT`:

``` sas
data work.stocks2;
  set pg2.stocks2(rename=Volume=CharVolume));
  Date2=input(Date,date9.);
  Volume=input(CharVolume,Comma12.);
  drop CharVolume;
Run;
```

Example for `PUT`:

``` sas
data atl_precip;
  SET pg2.weather_atlanta(rename=(date=CharDate));
  ZipCodeLast2=substr(put(ZipCode,z5.),4,2);
Run;
```
