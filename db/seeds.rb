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
                                  imagePath: "nfl_teams/nfcw/ari.jpg"
Team.create name: "Atlanta Falcons", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/atl.jpg"
Team.create name: "Baltimore Ravens", nfl: 1,
                                  imagePath: "nfl_teams/afcn/bal.jpg"
Team.create name: "Buffalo Bills", nfl: 1,
                                  imagePath: "nfl_teams/afce/buf.jpg"
Team.create name: "Carolina Panthers", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/car.jpg"
Team.create name: "Chicago Bears", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/chi.jpg"
Team.create name: "Cincinnati Bengals", nfl: 1,
                                  imagePath: "nfl_teams/afcn/cin.jpg"
Team.create name: "Cleveland Browns", nfl: 1,
                                  imagePath: "nfl_teams/afcn/cle.jpg"
Team.create name: "Dallas Cowboys", nfl: 1,
                                  imagePath: "nfl_teams/nfce/dal.jpg"
Team.create name: "Denver Broncos", nfl: 1,
                                  imagePath: "nfl_teams/afcw/den.jpg"
Team.create name: "Detroit Lions", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/det.jpg"
Team.create name: "Green Bay Packers", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/gb.jpg"
Team.create name: "Houston Texans", nfl: 1,
                                  imagePath: "nfl_teams/afcs/hou.jpg"
Team.create name: "Indianapolis Colts", nfl: 1,
                                  imagePath: "nfl_teams/afcs/ind.jpg"
Team.create name: "Jacksonville Jaguars", nfl: 1,
                                  imagePath: "nfl_teams/afcs/jac.jpg"
Team.create name: "Kansas City Chiefs", nfl: 1,
                                  imagePath: "nfl_teams/afcw/kc.jpg"
Team.create name: "Los Angeles Chargers", nfl: 1,
                                  imagePath: "nfl_teams/afcw/lac.jpg"
Team.create name: "Los Angeles Rams", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/lar.jpg"
Team.create name: "Minnesota Vikings", nfl: 1,
                                   imagePath: "nfl_teams/nfcn/min.jpg"
Team.create name: "Miami Dolphins", nfl: 1,
                                  imagePath: "nfl_teams/afce/mia.jpg"
Team.create name: "New England Patriots", nfl: 1,
                                  imagePath: "nfl_teams/afce/ne.jpg"
Team.create name: "New Orleans Saints", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/no.jpg"
Team.create name: "New York Giants", nfl: 1,
                                  imagePath: "nfl_teams/nfce/nyg.jpg"
Team.create name: "New York Jets", nfl: 1,
                                  imagePath: "nfl_teams/afce/nyj.jpg"
Team.create name: "Oakland Raiders", nfl: 1,
                                  imagePath: "nfl_teams/afcw/oak.jpg"
Team.create name: "Philadelphia Eagles", nfl: 1,
                                  imagePath: "nfl_teams/nfce/phi.jpg"
Team.create name: "Pittsburgh Steelers", nfl: 1,
                                  imagePath: "nfl_teams/afcn/pit.jpg"
Team.create name: "San Francisco 49ers", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/sf.jpg"
Team.create name: "Seattle Seahawks", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/sea.jpg"
Team.create name: "Tampa Bay Buccaneers", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/tb.jpg"
Team.create name: "Tennessee Titans", nfl: 1,
                                  imagePath: "nfl_teams/afcs/ten.jpg"
Team.create name: "Washington Football Team", nfl: 1,
                                  imagePath: "nfl_teams/nfce/was.jpg"
