# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create the admin user
admin = User.new do |u|
  u.name = "Admin"
  u.user_name = "Admin"
  u.admin = true
  u.supervisor = true
  u.activated = true
  u.activated_at = Time.zone.now
  u.email = "admin@fbpm.com"
  u.password = "p8ssw0rd"
  u.password_confirmation = "p8ssw0rd"
  u.phone = "512-924-6139"
end
admin.save!

Team.create name: "Arizona Cardinals", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/ari.svg"
Team.create name: "Atlanta Falcons", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/atl.svg"
Team.create name: "Baltimore Ravens", nfl: 1,
                                  imagePath: "nfl_teams/afcn/bal.svg"
Team.create name: "Buffalo Bills", nfl: 1,
                                  imagePath: "nfl_teams/afce/buf.svg"
Team.create name: "Carolina Panthers", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/car.svg"
Team.create name: "Chicago Bears", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/chi.svg"
Team.create name: "Cincinnati Bengals", nfl: 1,
                                  imagePath: "nfl_teams/afcn/cin.svg"
Team.create name: "Cleveland Browns", nfl: 1,
                                  imagePath: "nfl_teams/afcn/cle.svg"
Team.create name: "Dallas Cowboys", nfl: 1,
                                  imagePath: "nfl_teams/nfce/dal.svg"
Team.create name: "Denver Broncos", nfl: 1,
                                  imagePath: "nfl_teams/afcw/den.svg"
Team.create name: "Detroit Lions", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/det.svg"
Team.create name: "Green Bay Packers", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/gb.svg"
Team.create name: "Houston Texans", nfl: 1,
                                  imagePath: "nfl_teams/afcs/hou.svg"
Team.create name: "Indianapolis Colts", nfl: 1,
                                  imagePath: "nfl_teams/afcs/ind.svg"
Team.create name: "Jacksonville Jaguars", nfl: 1,
                                  imagePath: "nfl_teams/afcs/jac.svg"
Team.create name: "Kansas City Chiefs", nfl: 1,
                                  imagePath: "nfl_teams/afcw/kc.svg"
Team.create name: "Los Angeles Chargers", nfl: 1,
                                  imagePath: "nfl_teams/afcw/lac.svg"
Team.create name: "Los Angeles Rams", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/lar.svg"
Team.create name: "Minnesota Vikings", nfl: 1,
                                   imagePath: "nfl_teams/nfcn/min.svg"
Team.create name: "Miami Dolphins", nfl: 1,
                                  imagePath: "nfl_teams/afce/mia.svg"
Team.create name: "New England Patriots", nfl: 1,
                                  imagePath: "nfl_teams/afce/ne.svg"
Team.create name: "New Orleans Saints", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/no.svg"
Team.create name: "New York Giants", nfl: 1,
                                  imagePath: "nfl_teams/nfce/nyg.svg"
Team.create name: "New York Jets", nfl: 1,
                                  imagePath: "nfl_teams/afce/nyj.svg"
Team.create name: "Las Vegas Raiders", nfl: 1,
                                  imagePath: "nfl_teams/afcw/lv.svg"
Team.create name: "Philadelphia Eagles", nfl: 1,
                                  imagePath: "nfl_teams/nfce/phi.svg"
Team.create name: "Pittsburgh Steelers", nfl: 1,
                                  imagePath: "nfl_teams/afcn/pit.svg"
Team.create name: "San Francisco 49ers", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/sf.svg"
Team.create name: "Seattle Seahawks", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/sea.svg"
Team.create name: "Tampa Bay Buccaneers", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/tb.svg"
Team.create name: "Tennessee Titans", nfl: 1,
                                  imagePath: "nfl_teams/afcs/ten.svg"
Team.create name: "Washington Commanders", nfl: 1,
                                  imagePath: "nfl_teams/nfce/was.svg"
