require 'roo'

xlsx = Roo::Spreadsheet.open('games.xlsx')
puts xlsx.info

xlsx.sheets.each do |sheet|
  puts sheet
  (2..33).to_a.each do |row|
    puts xlsx.sheet(sheet).row(row).inspect
  end
end
