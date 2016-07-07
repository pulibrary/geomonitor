# Rake tasks to cleanup 
namespace :cleanup do
  desc 'Exports Statuses that are not in last 200 to a csv and then deletes them'
  task status: :environment do
    with_config do|_app, _host, db, _user|
      File.open("#{Rails.root}/data/archived_statuses_#{db}_#{Time.now.to_i}.csv", 'w') do |f|

        # Just write one header
        PgCsv.new(sql: Status.where(id: nil).to_sql, header: true, type: :yield).export do |row|
          f.write row
        end

        Layer.find_each do |layer|
          # grab the last 200 statuses for this layer
          last_ten = layer.statuses.last(200)

          # grab everything but the last 200
          old_statuses = Status.where(layer_id: layer.id).where.not(id: last_ten)

          # write statuses to a csv
          PgCsv.new(sql: old_statuses.to_sql, temp_file: true, temp_dir: "#{Rails.root}/data", type: :yield).export do |row|
            f.write row
          end

          # delete all old statuses
          old_statuses.delete_all
        end
      end
    end
  end

  desc 'delete wms layers'
  task delete_wms_layers: :environment do
    Geomonitor.get_all_document_ids.each do |name_id|
      # Check to see if the layer already exists
      l = Layer.find_by_name(name_id)
      if l
        doc = Geomonitor.find_document(name_id)
        if doc.present? && doc['uuid'].present?
          wms = JSON.parse(doc['dct_references_s']).try(:[], 'http://www.opengis.net/def/serviceType/ogc/wms')
          if wms
            l.destroy
          end
        end
      end
    end
  end

  desc 'delete iiif layers'
  task delete_iiif_layers: :environment do
    Geomonitor.get_all_document_ids.each do |name_id|
      # Check to see if the layer already exists
      l = Layer.find_by_name(name_id)
      if l
        doc = Geomonitor.find_document(name_id)
        if doc.present? && doc['uuid'].present?
          iiif = JSON.parse(doc['dct_references_s']).try(:[], 'http://iiif.io/api/image')
          if iiif
            l.destroy
          end
        end
      end
    end
  end

  desc 'delete host by url'
  task :delete_host, [:hosturl] => :environment do |t, args|
    host = Host.find_by(url: args[:hosturl])
    if host
      host.destroy
    end
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end
end
