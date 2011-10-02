# How I Got My iPad 2 #

## Skip this Part if You're Just Here to Get an iPad ##

We've all watched the keynote and read the blog posts, and now everyone wants one. The only problem is, everyone wants one *now*, and Apple only has so many. (Is it marketing? Or can they simply not keep up? Either way, it's an issue.) By about 3:30pm on March 18th, people were lined up from my Apple Store all the way to Nordstroms, at the other end of the (pretty lengthy) Cherry Creek mall. A lot of people had *actually brought lawn chairs*. That was as early as I could get there, because it was a Friday, and thus a regular day of school. The next day, they were already sold out, so I went online only to find that the shipping times were up to a couple of weeks. In a few more days, they hit 4-5 weeks. I would be leaving on spring break in just a week, and I wanted my iPad before then. Even if the online store didn't have such long waits, I discovered I wouldn't be able to use it because it wouldn't accept my debit card. So I was stuck buying an iPad from an actual, physical store, where the sales associates answer the phone by saying, "Hi, we are currently sold out of *every model* of the iPad 2. Is there anything else I can help you with today?"

So I did the usual stuff. I followed the "tips and tricks" that every tech blog recommends. I called the Apple Store every day to see if they had iPads. I called Target, Best Buy, and Walmart, too. (Even though the people at Best Buy were rude, and the people at Walmart just never picked up.) All of the non-Apple-Stores had a pathetic number of iPads. One morning Target said they got in three and sold out within minutes. From the Apple Store, I got the same response every time. "Come early if you want one, they usually sell out before we even open." Well, I couldn't do that, because school starts at 7:30, and the Apple Store (*only* on the days it opens early to sell iPads) opens at 9:00. My parents were willing to help out, but they weren't willing to wait in line for the *possibility* of receiving an iPad.

I was about ready to give up, until I saw someone post a link to [this article](http://log.maniacalrage.net/post/4030658171/tip-how-to-get-an-ipad-2-at-target-today-i "Tip: How to get an iPad 2 at Target") by Garrett Murray at Maniacal Rage. Target keeps their *live* and *extremely accurate* stock information in an online database which is accessible to the public by means of product ID numbers and zip codes. Better yet, someone had already done the work of [listing all of the iPad 2 product IDs](http://forums.macrumors.com/showpost.php?p=12159692&postcount=185), and the author of the article had used the database's URL query system to make a shell script that pulls and returns availability information for a given model in a given zip code. He even included some regex magic that strips off all the HTML. Awesome.

Now all I had to do was create a way to be notified *immediately* of any availability of the iPad I wanted within my area. This was just screaming out "AppleScript". So, lo and behold, I wrote up a script that ran the URL query with my zip code for the model I wanted, found any stores not listed as "Out of Stock", formatted them into an email, and sent the good news my way. I put all of this inside a loop that ran every 60 seconds. This meant that I got a ton of emails when the iPad finally *was* in stock, but that was okay with me. (I could have just made it exit the repeat loop after sending the email, but the systematic buzz of my phone every minute was a helpful indicator to let me know that it was time to step out of class to "use the bathroom" [read: urgently call parents, promising to pay them back and begging them to go pick it up from Target].) I ran the script for two days, and sure enough, it got me the iPad I wanted, and just in time, too.

## Okay. Here's my Magical Secret Trick™. ##

If you want an iPad and you've got Target stores in your area, just open up this script in AppleScript Editor and run it until you've found your shiny new device:

	-- USER INPUT
	set iPadWifiOr3G to button returned of (display dialog "Choose whether you're looking for a WiFi or a Wifi + 3G iPad." buttons {"WiFi", "WiFi+3G"})
	set iPadModel to iPadWifiOr3G
	if iPadWifiOr3G contains "WiFi+3G" then
		set iPadDataPlan to button returned of (display dialog "Select the carrier you'd like to use." buttons {"AT&T", "Verizon"})
		set iPadModel to iPadModel & " " & iPadDataPlan
	end if
	set iPadColor to button returned of (display dialog "Select the color of iPad you're looking for." buttons {"Black", "White"})
	set iPadModel to iPadModel & " " & iPadColor
	set iPadStorage to button returned of (display dialog "Select the size of iPad you're looking for." buttons {"16GB", "32GB", "64GB"})
	set iPadModel to iPadModel & " " & iPadStorage
	set alliPadModels to {"WiFi Black 16GB", "WiFi Black 32GB", "WiFi Black 64GB", "WiFi White 16GB", "WiFi White 32GB", "WiFi White 64GB", "WiFi+3G AT&T Black 16GB", "WiFi+3G AT&T Black 32GB", "WiFi+3G AT&T Black 64GB", "WiFi+3G AT&T White 16GB", "WiFi+3G AT&T White 32GB", "WiFi+3G AT&T White 64GB", "WiFi+3G Verizon Black 16GB", "WiFi+3G Verizon Black 32GB", "WiFi+3G Verizon Black 64GB", "WiFi+3G Verizon White 16GB", "WiFi+3G Verizon White 32GB", "WiFi+3G Verizon White 64GB"}
	set allCorrespondingTargetDCPINumbers to {"057-10-1830", "057-10-1831", "057-10-1832", "057-10-1839", "057-10-1840", "057-10-1841", "057-10-1833", "057-10-1834", "057-10-1835", "057-10-1842", "057-10-1843", "057-10-1844", "057-10-1836", "057-10-1837", "057-10-1838", "057-10-1845", "057-10-1846", "057-10-1847"}
	set DCPINumber to item indexOfItemInList(alliPadModels, iPadModel) of allCorrespondingTargetDCPINumbers
	set zipCode to text returned of (display dialog "Enter your zip code so nearby Target stores can be located and checked for iPad availability. (Only valid zip codes are allowed.)" default answer "Ex. 12345")
	repeat
		if (count of (characters of zipCode)) is 5 then
			try
				set zipCode to zipCode as number
				exit repeat
			on error
				set zipCode to text returned of (display dialog "That was not a valid zip code. Try again." default answer "Ex. 12345")
			end try
		else
			set zipCode to text returned of (display dialog "That was not a valid zip code. Try again." default answer "Ex. 12345")
		end if
	end repeat
	set emailAddress to text returned of (display dialog "Enter the email address at which you'd like to be notified when the iPad you're looking for becomes available. (And just do it right, because this one isn't getting checked.)" default answer "Ex. john.appleseed@me.com")

	--SCRIPT
	repeat
		set targetStoreiPadStockInfo to (do shell script "curl -s --data \"_dyncharset=ISO-8859-1&asin=&dpci=" & DCPINumber & "&zipcode=" & zipCode & "&city=&state=\" http://sites.target.com/site/en/spot/mobile_fiats_results.jsp?_DARGS=/site/en/spot/mobile_fiats.jsp | grep -A 2 strong | sed -e 's/<p><strong>//' -e 's/<\\/strong><br\\/>//' -e 's/<br \\/>//' -e 's/<\\/p>//' -e 's/--//' -e 's/^[ 	]*//;s/[ 	]*$//'") -- This is Garrett Murray's Shell Script. Thanks!
		set ASTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ((return as text) & (return as text))
		set targetStores to text items of targetStoreiPadStockInfo
		set AppleScript's text item delimiters to ASTID
		set targetStoresWithiPads to {}
		repeat with targetStore in targetStores
			if targetStore does not contain "Out Of Stock" then set targetStoresWithiPads to targetStoresWithiPads & targetStore
			--if targetStore contains "Out Of Stock" then set targetStoresWithiPads to targetStoresWithiPads & targetStore -- This is for testing. Don't use it.
		end repeat
		if (count of targetStoresWithiPads) is greater than 0 then
			set ASTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to ((return as text) & (return as text))
			set targetStoresWithiPadsString to (targetStoresWithiPads as string)
			set AppleScript's text item delimiters to ASTID
			set iPadAlertMessage to "The iPad 2 " & iPadModel & " is available in the following stores:" & (return as text) & (return as text) & targetStoresWithiPadsString & (return as text) & (return as text) & "Act fast!"
			tell application "Mail"
				set theNewMessage to make new outgoing message with properties {subject:"Your iPad is Available!", content:iPadAlertMessage, visible:false}
				tell theNewMessage
					make new to recipient at end of to recipients with properties {address:emailAddress}
					send
				end tell
			end tell
		end if
		delay 60
	end repeat

	--SUBROUTINES
	on indexOfItemInList(theList, theItem)
		set itemIndex to 0
		repeat with i from 1 to (count of items in theList)
			if (item i of theList) is equal to theItem then
				set itemIndex to i
				exit repeat
			end if
		end repeat
		return itemIndex
	end indexOfItemInList
	
That whole "user input" section of the script was added just to make it easier to customize the iPad search, and make the script more reusable (at least, by other people). You're welcome.

I sincerely hope this works for anyone reading this in hopes of procuring an iPad. You may have heard people say that Target stores tend to only stock the smaller models, but I had two stores come up that were stocking the 32GB model I wanted. Also, my Mom mentioned that they seemed to have most of the models when she was there picking mine up.

Nonetheless, good luck if you're using this! And feel free to do whatever you want with the code, I'm not attached to it in any way (aside from the warm fuzzy feeling it gave me to know that my unconventional plan worked), and really a lot of the credit goes to Garrett over at Maniacal Rage for explaining Target's system and writing that shell script in the first place.