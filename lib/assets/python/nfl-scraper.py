import sys
import time
import json
import getopt   # Parse command line arguments
import string
from bs4 import BeautifulSoup
#
# Use Undetected-chromedriver
#
import undetected_chromedriver as uc

#
# Use regular chromedriver
#
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

#============================================================================#
# Parse command arguments
#============================================================================#
def printHelpMsg(name):
    arg_help = "\n  {0} -v -y <year> -n <weekNumber> -f\
                \n    -y Year\
                \n    -n Week Number\
                \n    -f file output\
                \n    -e espn code"

    print(arg_help)

#
# Parse command line arguments
#
def parseArgs(argv):
    arguments = {}
    arguments['year'] = " "
    arguments['weekNumber'] = " "
    arguments['fileOutput'] = ""
    arguments['espn'] = ""

    try:
        opts, args = getopt.getopt(argv[1:], "y:n:fe", ["help"])
    except:
        printHelpMsg('parseArgs')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            printHelpMsg(argv[0])
            sys.exit(2)
        elif opt in ("-y"):
            arguments["year"] = arg
        elif opt in ("-n"):
            arguments["weekNumber"] = arg
        elif opt in ("-f"):
            arguments["fileOutput"] = True
        elif opt in ("-e"):
            arguments["espn"] = True

    if arguments["year"] == " " or arguments["weekNumber"] == " ":
        printHelpMsg('parseArgs')
        sys.exit(2)

    return arguments

def testSetup():
    driver = uc.Chrome(headless=True,use_subprocess=False)
    driver.get('https://nowsecure.nl')
    time.sleep(10)
    driver.save_screenshot('nowsecure.png')

# Verify setup is working
#testSetup()
#sys.exit(2)

def getNFLGames_nfl(doc):

    # Get games information
    games = {}
    games["game"] = []

    # Get all games for each day and loop through them
    for game_group in doc.find_all("section", {"class": "nfl-o-matchup-group"}):

        # Get the date for the games in this group
        game_date = game_group.find("h2", {"class": "d3-o-section-title"}).text

        # Get details for each game on that day
        for game_details in game_group.find_all("div", {"class": "nfl-c-matchup-strip"}):

            game_final=""

            # Get team names
            teams = game_details.find_all("span", {"nfl-c-matchup-strip__team-fullname"})
            if teams:
                # Get away team
                away_team = teams[0].text.strip()
                # Get home team
                home_team = teams[1].text.strip()

            # This is set if the date is TBD or if the game is FINAL
            game_period = game_details.find("p", {"class": "nfl-c-matchup-strip__period"})

            # The NFL has certain games on some weeks marked as TBD because of flex
            # scheduling for those weeks, and they won't be scheduled until later in the
            # season. So, if the game_period is set then it is either a FINAL game or a
            # TBD game.  If it's a TBD or FINAL game then set game_time, game_timezone, and
            # game_network to None. If it's a fINAL game then get game scores.  If
            # game_period is not set then it's a normal game and set date-time, timezone,
            # and network
            if game_period:
                game_period = game_period.getText()
                if "TBD" or "FINAL" in game_period:
                    #print("Game_period is TBD...")
                    game_time = None
                    game_timezone = None
                    game_network = None
                    home_score = None
                    away_score = None

                if "FINAL" in game_period:
                    #print("Game_period is FINAL...")
                    # Mark game final
                    game_final="FINAL"

                    # Get scores
                    teamScores = game_details.find_all("div", {"nfl-c-matchup-strip__team-score"})
                    if teams:
                        # Get away team
                        away_score = teamScores[0]['data-score']
                        # Get home team
                        home_score = teamScores[1]['data-score']
            else:
                # Get time, timezone, and network
                game_time = game_details.find("span", {"class": "nfl-c-matchup-strip__date-time"}).text.strip()
                game_timezone = game_details.find("span", {"class": "nfl-c-matchup-strip__date-timezone"}).text.strip()
                game_network = game_details.find("p", {"class": "nfl-c-matchup-strip__networks"}).getText()
                home_score = None
                away_score = None

            game = {}
            game = dict({"date": game_date, "time": game_time, "timezone": game_timezone,
                         "away_team": away_team, "away_score": away_score,
                         "home_team": home_team, "home_score": home_score,
                         "network": game_network, "final": game_final })
            games["game"].append(game)

    return games

def getNFLGames_espn(doc):

    # Get games information
    games = {}
    games["game"] = []
    game_network = ""

    # Get all games for each day and loop through them
    for game_group in doc.find_all("div", {"class": "ScheduleTables--nfl"}):

        # Get the date for the games in this group
        game_date = game_group.find("div", {"class": "Table__Title"}).text
        #print(f"game_date: {game_date}\n")

        # Get details for each game on that day
        for game_details in game_group.find_all("tr", {"class": "Table__TR--sm"}):
            #print(f"game_details: \n{game_details}\n")

            game_final=""

            # Get team names
            for teams in game_details.find_all("span", {"class": "Table__Team"}):
                children = teams.findChildren("a" , recursive=False)
                href = children[0]['href'].split('/')
                team_name = href[-1].replace('-', ' ')
                team_name = string.capwords(team_name, sep = None)
                if len(teams["class"]) != 1:
                    # Get away team
                    away_team = team_name
                    #print(f"away_team: {away_team}")
                else:
                    # Get home team
                    home_team = team_name
                    #print(f"home_team: {home_team}")

            # This is set if the date is TBD or the game is not final
            # It is not set if the game is final
            game_period_block = game_details.find("td", {"class": "date__col"})
            if game_period_block:
                #print(f"game_period_block: {game_period_block}")
                game_time = game_period_block.find("a", {"class": "AnchorLink"}).getText()
                #print(f"game_time: {game_time}")

                #
                #  ESPN is odd, in that when the game is on ESPN or ABC they don't just
                #  add it like the other networks.  They show it as an image, so....need
                #  to look for those by checking for <figure> with class of network-espn or
                #  network-abc
                #
                if game_time != "TBD":
                    network_container = game_details.find("div", {"class": "network-container"})
                    network = network_container.find("div", {"class": "network-name"})
                    if network:
                        game_network = network.getText()
                    else:
                        network = network_container.find("figure", {"class": "network-espn"})
                        if network:
                            game_network = "ESPN"
                        network = network_container.find("figure", {"class": "network-abc"})
                        if network:
                            if game_network:
                                game_network = game_network + " ABC"
                            else:
                                game_network = "ABC"
                    #print(f"game_network: {game_network}")

                home_score = None
                away_score = None

            else:
                game_final="FINAL"
                game_time = ""
                #
                # If there is no network-container element then the game is fINAL
                # and can get the scores.
                #
                game_row_tds = game_details.find_all("td", {"class": "Table__TD"})
                #print(f"game_row_tds: {game_row_tds}")
                game_scores = game_row_tds[2].find("a", {"class": "AnchorLink"}).getText()
                game_scores = game_scores.replace(',', '').split()
                #print(f"game_scores: {game_scores}")
                home_score = game_scores[3]
                away_score = game_scores[1]



            game = {}
            # -----HACK ALERT------
            # ESPN site doesn't put the timezone in the data.  They show the time in
            # the local timezone. Leaving timezone blank and letting rails app
            # set correctly
            game = dict({"date": game_date, "time": game_time, "timezone": "",
                         "away_team": away_team, "away_score": away_score,
                         "home_team": home_team, "home_score": home_score,
                         "network": game_network, "final": game_final })
            games["game"].append(game)


    return games

################
#  Main Code   #
################
arguments = parseArgs(sys.argv)
year = arguments['year']
week = arguments['weekNumber']
fileOutput = arguments['fileOutput']
espn = arguments['espn']

# path for NFL site, if it works
if espn:
    path = f"https://www.espn.com/nfl/schedule/_/week/{week}/year/{year}/seasontype/2"
else:
    path = f"https://www.nfl.com/schedules/{year}/REG{week}"
#print(f"path: {path}")

try:
    if espn:
        #
        # Use regular chromedriver
        #
        options = Options()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        #driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
        driver = webdriver.Chrome(options=options)
    else:
        #
        # Use undetected-chromedriver
        #
        uc_options = uc.ChromeOptions()
        uc_options.add_argument('--headless')
        driver = uc.Chrome(options=uc_options, use_subprocess=False)


    driver.get(path)

    wait = WebDriverWait(driver, timeout=25)
    if espn:
        wait.until(EC.visibility_of_element_located((By.CLASS_NAME, 'ScheduleTables--nfl')))
    else:
        # NFL site
        wait.until(EC.visibility_of_element_located((By.CLASS_NAME, 'nfl-o-matchup-group')))
except:
    e = repr(sys.exception())
    print(f"Exception has been thrown: {e}")
    driver.close()
    sys.exit(2)

doc = BeautifulSoup(driver.page_source, 'html.parser')

if espn:
    # ESPN site - can use regular chromedriver
    games = getNFLGames_espn(doc)
else:
    # NFL site - requires undetected-chromedriver
    games = getNFLGames_nfl(doc)

# Write out the games file
if fileOutput:
    filepath = f"{year}-week{week}_games"
    print("Printing to file...", filepath)
    file = open(filepath, "w")
    file.write(json.dumps(games, indent=2))
    file.close()
else:
    if games:
        print(json.dumps(games))
