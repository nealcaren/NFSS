NFSS Analysis Replication
====
This project attempts to reproduce the analysis reported here:
>Mark Regnerus, How different are the adult children of parents who have same-sex relationships? Findings from the New Family Structures Study, Social Science Research, Volume 41, Issue 4, July 2012, Pages 752-770, ISSN 0049-089X, 10.1016/j.ssresearch.2012.03.009. http://www.sciencedirect.com/science/article/pii/S0049089X12000610

The data was made available by the PI through ICPSR: http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34392

The code is in Stata because that is the software program I know best for data management and analysis. This should work with all versions of Stata, but does use the esttab command to produce the final tables. You can install that by typing, "ssc install esttab" in Stata.

In this beta version of the project, this code constructs all of the explanatory and outcome variables and analyzes the data, as per the original article, with a few caveats:

* I haven't quite figured out yet how stepfamily and single parent are operationalized. I have measures, but the counts are not the same as reported in the article.  In contrast, "intact biological family", "gay father", "lesbian mother", "adopted before two" and "divorced late" all have counts that match the article, so the models can estimate comparisons between those groups. That is, you can test whether or not the gf/lm coefficients are significantly different from the ibf coefficient.
*	With one exception, all of the control variables have been constructed. Since the data includes region but no state identifier, the state LGBT friendliness variables can't be reconstructed.
*  As noted in the do file, a few of the outcome variables have slightly different means and counts then reported in the article. If someone could provide some code to replicate those outcomes exactly, that would be great.


