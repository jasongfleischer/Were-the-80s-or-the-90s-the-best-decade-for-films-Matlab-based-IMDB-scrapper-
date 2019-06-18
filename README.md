# Were the 80's or the 90s the best decade for creating iconic films?

Back in 2015 I wrote this IMdB scraper in MATLAB because I was crazy and hadn't learned python yet.

Arguments on social media about good movies are always "she said, he said".  I decided to get some quantitative proof. 

I want to test a theory that the mid 80s (specifically 84-86) were unusually good at generating "classic/iconic" movies or if I just think so because that's my teen years. I mean, come on, Ghostbusters? The Breakfast Club? Alien? Stand By Me? To address this question I'm going to use MATLAB to scrape data off of IMDB and look at the top 100 movies in terms of US Box office.  I'm going to try to figure out how to use various combinations of the average user rating and/or # of rating votes as a measure of 'classic-ness', and look at how that measure changes from year to year.

The scraper code depends on features of IMdB's HTML that were good in March 2015, but have probably been modified since.  

If you just want to have a laugh, open and read the PDF.  If you hate yourself and want to try a similar trick feel free to open the .m/.mat
