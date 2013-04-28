desc "Tasks related to OGC Features"
namespace :features do

  desc "Tasks associated with generating"
  namespace :generate do

    desc "Generates CSV of features. Specify +count+ as the number of features to generate"
    task :csv, [:count] => [:environment] do |t, args|

      # Default the count to 1000
      args.with_defaults(count: 1000)

      Rails.logger.info "Generating a CSV with #{args[:count]} features."

      csv_string = CSV.generate do |csv|
        csv << ["latitude", "longitude"]

        count = args[:count].to_i
        count.times do |i|
          lng = rand * (360) - 180
          lat = rand * (180) - 90
          csv << [lat, lng]
        end
      end

      puts csv_string

    end

  end
end
