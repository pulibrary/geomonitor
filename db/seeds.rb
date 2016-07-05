# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'json'

data = JSON::parse(File.read('data/transformed.json'))

data.each do |doc|
  next unless doc['dct_provenance_s']
  wms = JSON.parse(doc['dct_references_s']).try(:[], 'http://www.opengis.net/def/serviceType/ogc/wms')
  if wms
    wms = wms.gsub('/wms', '')
    doc_institution = doc['dct_provenance_s']
    institution = Institution.find_or_create_by(name: doc_institution)
    host = Host.find_or_create_by(url: wms, institution_id: institution.id) do |host|
      host.name = "#{institution.name}"
    end
    begin
      georss_bbox = doc['georss_box_s'].split(' ')
      Layer.create(
        name: doc['layer_slug_s'],
        host_id: host.id,
        geoserver_layername: doc['layer_id_s'],
        access: doc['dc_rights_s'],
        bbox: "#{georss_bbox[1]} #{georss_bbox[0]} #{georss_bbox[3]} #{georss_bbox[2]}",
        active: true
      )
    rescue NoMethodError => e
      Rails.logger.error "#{e} for #{doc['layer_slug_s']}"
    end
  end
end
