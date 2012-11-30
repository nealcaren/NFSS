NFSS Analysis Replication
====
This project attempts to reproduce the analysis reported here:
>Mark Regnerus, How different are the adult children of parents who have same-sex relationships? Findings from the New Family Structures Study, Social Science Research, Volume 41, Issue 4, July 2012, Pages 752-770, ISSN 0049-089X, 10.1016/j.ssresearch.2012.03.009. http://www.sciencedirect.com/science/article/pii/S0049089X12000610

> Mark Regnerus, How different are the adult children of parents who have same-sex relationships? Findings from the New Family Structures Study, Social Science Research, Volume 41, Issue 4, July 2012, Pages 752-770, ISSN 0049-089X, 10.1016/j.ssresearch.2012.03.009.
http://www.sciencedirect.com/science/article/pii/S0049089X12000610

The data was made available by the PI through ICPSR: http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34392

The code is in Stata because that is the software program I know best for data management and analysis. This should work with all versions of Stata, but does use the esttab command to produce the final tables. You can install that by typing, "ssc install esttab" in Stata.

In this alpha version of the project, this code constructs most of the independent variables Regnerus used as well as some of the dependent variables, and then performs some regressions. My goal is for the code to run all of the regressions reported in the original paper. It would great if the code could completely reproduce the original analysis so that more scholars could contribute to this conversation without having to do all the data management work. You can contribute to the code either through the standard Github mechanism or by sending me an email (neal.caren@gmail.com).

As of 11/30:

* I haven't quite figured out yet how stepfamily and single parent are operationalized, so I lump them with other family forms. I have figured out, "intact biological family", "gay father", "lesbian mother", "adopted before two" and "divorced late" so the models can estimate comparisons between those groups. That is, you can test whether or not the gf/lm coefficients are significantly different from the ibf coefficient.
*	With one exception, all of the control variables have been constructed. Since the data includes region but no state identifier, the state LGBT friendliness variables can't be reconstructed.
* I've recoded some of the binary outcome measures, one of the continuous measures, and none of the count outcomes. I focused on the ones where there were significant differences reported between lm/gf and ibf families.
* Of particular interest to me is the role of class background. The original model includes a measure of family of origin income, but my preliminary findings suggest that many of the statistical significant effects associated with family form disappear if you add an additional control for receiving welfare as a child. 


