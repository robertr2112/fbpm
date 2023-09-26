import sys
import time
import json
import getopt   # Parse command line arguments
from bs4 import BeautifulSoup
import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait

#============================================================================#
# Parse command arguments
#============================================================================#
def printHelpMsg(name):
    arg_help = "\n  {0} -v -y <year> -n <weekNumber> \
                \n    -y Year\
                \n    -n Week Number"

    print(arg_help)

#
# Parse command line arguments
#
def parseArgs(argv):
    arguments = {}
    arguments['year'] = " "
    arguments['weekNumber'] = " "

    try:
        opts, args = getopt.getopt(argv[1:], "y:n:", ["help"])
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

def getNFLGames(doc):

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


################
#  Main Code   #
################
arguments = parseArgs(sys.argv)
year = arguments['year']
week = arguments['weekNumber']

uc_options = uc.ChromeOptions()
uc_options.headless = True
uc_options.add_argument("--headless")

driver = uc.Chrome(options=uc_options)
path = f"https://www.nfl.com/schedules/{year}/REG{week}"
#print(path)
driver.get(path)

### Wait for the javascript content to load ###
#revealed = driver.find_element(By.ID, "main-content")
revealed = driver.find_element(By.CLASS_NAME, "nfl-o-matchup-group")
wait = WebDriverWait(driver, timeout=10)

#driver.find_element(By.ID, "main-content")
driver.find_element(By.CLASS_NAME, "nfl-o-matchup-group")
wait.until(lambda d : revealed.is_displayed())

#doc = Nokogiri::HTML(driver.page_source)
doc = BeautifulSoup(driver.page_source, 'html.parser')

# Write out the html file
#filepath = f"week{week}.html"
#file = open(filepath, "w")
#file.write(str(doc.prettify()))
#file.close()

#print(doc)
games = getNFLGames(doc)

# Write out the games file
#filepath = f"week{week}_games"
#file = open(filepath, "w")
#file.write(json.dumps(games, indent=2))
#file.close()

print(json.dumps(games))

#driver.find_element("xpath","//*[@id='onetrust-accept-btn-handler']").click();
#driver.save_screenshot('screenie.png')
