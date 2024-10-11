# rake golfnow:read_data
namespace :golfnow do
  desc "Read and process Golfnow Data.xlsx"
  task read_data: :environment do
    file_path = Rails.root.join('Golfnow Data.xlsx')
    xlsx = Roo::Excelx.new(file_path)

    sheet = xlsx.sheet(0)

    sheet.each_with_index(headers: true) do |row, index|
      next if index == 0

      cleaned_row = row.to_hash.transform_values do |value|
        value.is_a?(String) ? value.gsub("\n", '').strip : value
      end

      Course.create(
        course_name: cleaned_row["Facility Name"],
        course_location: cleaned_row["Address"],
        status: :approved,
        user_id: User.first.id
      )
      puts "Row #{index}: #{cleaned_row}"
    end
  end
end
