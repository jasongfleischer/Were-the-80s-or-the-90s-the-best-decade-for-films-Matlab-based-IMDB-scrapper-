%%
% imdb_scrape.m
% written by Jason G. Fleischer
%
% (for those of you who have never read a computer program before, the % at
% the start of a line means "this is a comment for humans to read, and not
% instructions for the software")
%
% Based on an argument we had on The Facebook, I want to test a theory that 
% the mid 80s (specifically 84-86) were unusually good at generating 
% "iconic" movies or if it just feels way that because I was a teen then.
% To address this question I'm going to use MATLAB to scrape data off of
% IMDB and look at the top 100 movies in terms of US Box office.  I'm going
% to try to figure out how to use various combinations of the average user 
% rating and/or # of rating votes as a measure of 'classic-ness', and look 
% at how that measure changes from year to year. 
%
% AT THIS POINT, UNLESS YOU LIKE READING CODE YOU SHOULD 
% PROBABLY SKIP AHEAD TO THE RESULTS

% Note that my solution is hard-coded to features of the
% current IMDB html... its going to fail if they change anything
% Please pardon the messiness of this code, and know that this is probably
% the best code commenting I've done in years :)
%
% This code is tested and working in MATLAB R2013a and IMDB's website as of
% March 13, 2015
% 
% Please feel free to use and adapt this code.  I would like to hear from
% you if you have a different analysis/viewpoint on this data.
% email: jason.g.fleischer@gmail.com

%% Fetch the data
years=[1964:2004]; % let's not even worry about films that are less than 10 years old, its impossible to decide if they are classic/iconic yet 

data={}; % data includes title for later exploration
allvotes=[]; % for convenience we'll use these matrices for raw summary statistics
allratings=[];
xi=0;
for xx=years,
    xi=xi+1; 
    disp(['Scraping ' num2str(xx)]);
    s1=urlread(sprintf('http://www.imdb.com/search/title?at=0&sort=boxoffice_gross_us&title_type=feature&year=%s,%s',num2str(xx),num2str(xx)));
    s2=urlread(sprintf('http://www.imdb.com/search/title?at=0&sort=boxoffice_gross_us&start=51&title_type=feature&year=%s,%s',num2str(xx),num2str(xx)));
    allscrape=[s1 s2]; % imdb only serves 50 movies on a page, combine two pages to get the reqd data
    indxs=strfind(allscrape,'wlb_wrapper'); % this string marks the beginning of a film's entry in the html
    % one each page we get 50 of these wlb_wrappers for movies plus one extra at the end of the page
    yi=0;
    for yy=[1:50 52:101] % skip the end-of-page wlb_wrapper
        yi=yi+1;
        first=indxs(yy);
        last=indxs(yy+1);
        toParse=allscrape(first:last); % substring we will parse for the film info
        % the title lays in the beginning, right between a </span> and the next <span>
        tinds=strfind(toParse,'span');
        temp=toParse(tinds(1)+5:tinds(2)-2); % remove the spans
        titl=strtrim(temp);
        % rating is here
        rind=strfind(toParse,'Users rated this');
        rating=str2num(toParse(rind+16:rind+19));
        % the number of votes lies right after the rating a fixed number of
        % spaces because the format is always: 
        % Users rated this X.Y/10 (ZZZ,ZZZ votes)
        vind1=rind+25;
        vind2=strfind(toParse(vind1:(vind1+20)),'votes')+vind1-3;
        votesStr=toParse(vind1:vind2); % this is the number in ZZZ,ZZZ format
        remove=strfind(votesStr,','); % get rid of the commas
        keep=setdiff(1:length(votesStr),remove); 
        votes=str2num(votesStr(keep)); % numerical format
        allvotes(yi,xi)=votes;
        allratings(yi,xi)=rating;      
        record.title=titl;
        record.rating=rating;
        record.votes=votes;
        record.year=xx;
        data{end+1}=record;
    end
end


        
%% Results
% first questions:  how do the distributions look for rating and votes?

figure; hist(allvotes(:));  title('Histogram of # votes'); 
xlabel('value'); ylabel('count');
figure; hist(allratings(:)); title('Histogram of ratings'); 
xlabel('value'); ylabel('count');


% Answer: ratings seem close to normally distributed, # votes is
% nowhere near... very exponential-ish.  I've looked at the distribution of
% votes in individual years as well, and its pretty much always like that,
% every year, as well as across all years. 
%    
% But even worse, there is a disturbing non-sataionarity in the votes data:

figure; plotyy(1964:2004,mean(allratings),1964:2004,mean(allvotes)); 
legend('mean ratings','mean number of votes'); xlabel('release year')
 
% The mean number of votes increases year on year! I'm guessing this is
% because more people are discovering IMDB every year, and they vote on the
% movies they have seen that year.  This means that there is no easy threshold
% criteria to define a classic by # of votes. 
% This is very annoying because I'd hoped votes would be the way to
% quantify this.  It's clear that people's ratings of movies can be very
% multi-modal: true fans love Star Trek movies, everyone else finds them
% mostly blah. I figured that lots of votes would indicate that people
% cared about a movie, either way.
%
% Interestingly, the mean ratings go up in the past, even as the number of
% votes drops tremendously. Perhaps only classic film buffs and true fans 
% vote that far back?
%
% let's look at ratings... to give you an idea of how IMDB ratings look
% here's some 1986 films that get the following ratings
% 5-6: 9 1/2 weeks, The Golden Child, Maximum Overdrive
% 6-7: Top Gun, Pretty in Pink, Short Circuit
% 7-8: Ferris Bueller, Blue Velvet, Transformers: The Movie
% 8+:  Aliens, Platoon, Stand by Me
%
% In other words high ratings probably don't correlate much with high brow,
% which suggests that depending on what your tastes are, IMDB
% ratings may not be good predictors of an iconic/classic movie
%
figure; plot(1964:2004,sum(allratings>6.5),1964:2004,sum(allratings>7),1964:2004,sum(allratings>7.5),1964:2004,sum(allratings>8)); 
legend('# films rating > 6.5','# films rating > 7','# films rating > 7.5','# films rating > 8')
xlabel('release year')

% Looking at thresholded ratings, we can see that a "hardline" stance on
% defining a classic (>8) puts it down to quite a constant (and low) level of
% achievement across years.  Using a lesser threshold results in peaks and
% valleys from year to year, and big trends such as observed previously
% where the dim past gets "grade inflation"
%
% This view of user ratings suggests two things:
% 1. It's less that 84-86 were good, and more that the early 80s were terrible
% 2. There's a very interesting bump in 1993 (mostly 7.5-8 movies) and another
% bump in 1995 (>8 movies).
%
% Here's all 7.5+ movies in 1993-1995:
minds=find(allratings(:,1993-1964+1:1995-1964+1)>7.5);
ms=data(((1993-1964)*100+1):((1996-1964)*100));
for xxx=minds', fprintf('%s (%d) rating %f on %d votes\n',ms{xxx}.title,ms{xxx}.year,ms{xxx}.rating,ms{xxx}.votes); end

% Jurassic Park (1993) rating 8.000000 on 462483 votes
% The Fugitive (1993) rating 7.800000 on 192198 votes
% Schindler&#x27;s List (1993) rating 8.900000 on 715416 votes
% Philadelphia (1993) rating 7.700000 on 160734 votes
% The Nightmare Before Christmas (1993) rating 8.000000 on 196344 votes
% Groundhog Day (1993) rating 8.100000 on 362638 votes
% Tombstone (1993) rating 7.800000 on 84631 votes
% Falling Down (1993) rating 7.600000 on 122628 votes
% The Piano (1993) rating 7.600000 on 58165 votes
% Carlito&#x27;s Way (1993) rating 7.900000 on 147469 votes
% The Joy Luck Club (1993) rating 7.600000 on 11912 votes
% The Sandlot (1993) rating 7.800000 on 49878 votes
% In the Name of the Father (1993) rating 8.100000 on 89507 votes
% The Remains of the Day (1993) rating 7.900000 on 41076 votes
% A Bronx Tale (1993) rating 7.800000 on 87713 votes
% Iron Monkey (1993) rating 7.600000 on 12180 votes
% True Romance (1993) rating 8.000000 on 144871 votes
% The Lion King (1994) rating 8.500000 on 506259 votes
% Forrest Gump (1994) rating 8.800000 on 997788 votes
% Pulp Fiction (1994) rating 8.900000 on 1094646 votes
% Interview with the Vampire: The Vampire Chronicles (1994) rating 7.600000 on 214666 votes
% The Crow (1994) rating 7.600000 on 122681 votes
% L&#xE9;on: The Professional (1994) rating 8.600000 on 596173 votes
% The Shawshank Redemption (1994) rating 9.300000 on 1411949 votes
% Il Postino: The Postman (1994) rating 7.800000 on 23549 votes
% Se7en (1995) rating 8.700000 on 837218 votes
% Die Hard: With a Vengeance (1995) rating 7.600000 on 263543 votes
% Braveheart (1995) rating 8.400000 on 616919 votes
% Heat (1995) rating 8.300000 on 370225 votes
% Twelve Monkeys (1995) rating 8.100000 on 394927 votes
% Sense and Sensibility (1995) rating 7.700000 on 68275 votes
% Casino (1995) rating 8.200000 on 277263 votes
% Dead Man Walking (1995) rating 7.600000 on 66883 votes
% Leaving Las Vegas (1995) rating 7.600000 on 85123 votes
% Toy Story (1995) rating 8.300000 on 495702 votes
% The Usual Suspects (1995) rating 8.700000 on 618686 votes


% For comarpison here's all 7.5+ movies in 1984-86
minds=find(allratings(:,1984-1964+1:1986-1964+1)>7.5);
ms=data(((1984-1964)*100+1):((1987-1964)*100));
for xxx=minds', fprintf('%s (%d) rating %f on %d votes\n',ms{xxx}.title,ms{xxx}.year,ms{xxx}.rating,ms{xxx}.votes); end

% Ghostbusters (1984) rating 7.800000 on 226508 votes
% Indiana Jones and the Temple of Doom (1984) rating 7.600000 on 270070 votes
% The Natural (1984) rating 7.600000 on 31718 votes
% The Terminator (1984) rating 8.100000 on 489628 votes
% The Killing Fields (1984) rating 7.900000 on 38849 votes
% Once Upon a Time in America (1984) rating 8.400000 on 185081 votes
% This Is Spinal Tap (1984) rating 8.000000 on 95116 votes
% Blood Simple. (1984) rating 7.700000 on 60283 votes
% Amadeus (1984) rating 8.400000 on 227921 votes
% Kaos (1984) rating 7.900000 on 1537 votes
% Repentance (1984) rating 8.500000 on 2300 votes
% La guerre des tuques (1984) rating 7.600000 on 1271 votes
% Love Streams (1984) rating 7.900000 on 2429 votes
% Back to the Future (1985) rating 8.500000 on 582009 votes
% The Color Purple (1985) rating 7.800000 on 54327 votes
% The Goonies (1985) rating 7.800000 on 153101 votes
% The Breakfast Club (1985) rating 7.900000 on 216290 votes
% The Purple Rose of Cairo (1985) rating 7.700000 on 31347 votes
% After Hours (1985) rating 7.700000 on 33898 votes
% Brazil (1985) rating 8.000000 on 137118 votes
% My Life as a Dog (1985) rating 7.700000 on 13238 votes
% The Trip to Bountiful (1985) rating 7.600000 on 2743 votes
% The Adventures of Mark Twain (1985) rating 7.600000 on 1650 votes
% Mishima: A Life in Four Chapters (1985) rating 7.900000 on 4617 votes
% Hey Babu Riba (1985) rating 7.700000 on 522 votes
% Ran (1985) rating 8.300000 on 66084 votes
% Platoon (1986) rating 8.100000 on 249217 votes
% Aliens (1986) rating 8.400000 on 412480 votes
% Ferris Bueller&#x27;s Day Off (1986) rating 7.900000 on 212114 votes
% Stand by Me (1986) rating 8.100000 on 229781 votes
% Hannah and Her Sisters (1986) rating 8.000000 on 46048 votes
% Hoosiers (1986) rating 7.600000 on 30857 votes
% Blue Velvet (1986) rating 7.800000 on 113599 votes
% The Name of the Rose (1986) rating 7.800000 on 73393 votes

% Whew!! Still with me?  
%
% It looks like my theory is pretty wrong, but then
% again, what good is a theory if you don't go to bat for it?  I'll make
% one more argument that I hope you'll find attractive.  Again we fall back
% on the questions: how can we extract "classic-ness" out of this data set?
% How can we seperate Groundhog Day (clearly a classic!) from The Sandlot
% (which as good a movie as it is, just doesn't meet my personal standards.
% Most importantly how can we remove Iron Monkey-like results from the
% above list?  I mean, who actually saw Iron Monkey, let alone liked it?
%
% I will argue that we need a metric that takes into account these things: 
% 1) Ratings 
% 2) Votes (get rid of low-vote Iron Monkey fanboy noise in the ratings) 
% 3) the upward trend of vote #s with year.  
% 
% Viola... we will use the mean rating of the most-voted-on movies in each 
% year.  I did some complicated stuff taking the 90th percentile+ voted
% movies originally, in order to account for year-to-year variability in
% how many movies lived out there in the long-tail of the vote
% distribution.  But it turned out that just using the top 10 vote-getters
% produced an essentially-identical graph: 

for xx=1:length(years), [dummy ginds]=sort(allvotes(:,xx),'descend'); ts(xx)=mean(allratings(ginds(1:10),xx)); end
figure; plot(1964:2004,ts); legend('Mean rating of top 10 vote-getters each year');

% Well crap.  The mid 80s are better than the early 80s, but still nothing
% on 1993.
%
% In conclusion, I couldn't figure out how to use this data to show what I
% know to be true: the 1980s are superior movie years. No matter how they
% were massaged, the analyses continue to point to the superiority of the
% mid 90s over the mid 80s in producing "classic/iconic" movies. These
% results are clearly counter to ground truth, and thus I conclude that
% IMDB's DB must have been corrupted by hackers.  Thanks Obama.

rt=80; vt=80; 
% I played around with percentiles until I got the results I wanted to see
rthrsh=prctile(allratings,rt);
vthrsh=prctile(allvotes,vt);
% if some movie from 1964 can't get at least 25,000 votes then it isn't a
% modern classic.  Threshold picked by eye on 1964-67 films to make sure
% ones I liked made it and ones I'd never heard of didn't  
vthrsh=max(vthrsh,25000); 
rthrshM=repmat(rthrsh,100,1);
vthrshM=repmat(vthrsh,100,1);
classics=(allratings>rthrshM & allvotes>vthrshM);
nclassics=sum(classics);
meanR=zeros(size(years));
zratings=zscore(allratings);
zvotes=zscore(allvotes);
zclassic=zscore(zratings.*zvotes);
meanZClassic=zeros(size(years));
meanZCv=zeros(size(years));
meanZCr=zeros(size(years));


for xx=1:length(years),
    tchk=find(classics(:,xx));
    tchk=tchk+(xx-1)*100;
    for xxx=tchk', 
        fprintf('%s (%d) rating %f on %d votes\n',data{xxx}.title,data{xxx}.year,data{xxx}.rating,data{xxx}.votes); 
        meanR(xx)=meanR(xx)+data{xxx}.rating;
        meanZClassic(xx)=meanZClassic(xx)+zclassic(xxx);
        meanZCr(xx)=meanZCr(xx)+zvotes(xxx);
        meanZCv(xx)=meanZCv(xx)+zratings(xxx);

    end
end
meanR=meanR./nclassics;
%meanZClassic=meanZClassic./nclassics;

figure; plotyy(1964:2004,nclassics,1964:2004,meanR); 
title(sprintf('Classics by year (%d/%d)',rt,vt));
legend('Number of classics','Mean rating of classics');

% 1964:2004, meanZClassic./nclassics
figure; plot(1964:2004,meanZClassic, 1964:2004, meanZCv, 1964:2004, meanZCr); 
title(sprintf('Sum of scores by year for classic movies (%d/%d)',rt,vt));
legend('Zclassic', 'Zvotes', 'Zratings')
