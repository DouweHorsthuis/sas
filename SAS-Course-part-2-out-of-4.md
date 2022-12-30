SAS Course part 2 out of 4
================
Douwe Horsthuis
2022-12-29

# Data step

## Order

The order in the data step is important for some specific statments, but
not all. During the dataphase there are 2 steps, **COMPILATION** and
**EXECUTION**. In the complilation step SAS establish data attributes
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

### Execution

SAS does 5 things in the execution phase:

1.  Initialize PDV.

2.  Read a row from the input table into the PDV.

3.  Sequentially process statements and update values in the PDV.

4.  At end of the step, write the contents of the PDV to the output
    table.

5.  Return to the top of the DATA step

# Debugging

When you use the software (enterprise) you can use the debugger. This
will show you line by line if you run into errors and how your data
behaves row by row.

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
