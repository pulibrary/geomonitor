class Ping < ActiveRecord::Base
  belongs_to :host, counter_cache: true, touch: true

  def self.check_status(host)

    url = self.host_url(host)

    Geomonitor.logger.debug "Pinging #{url} ..."
    begin
      p = Net::Ping::HTTP.new(url).ping?
    rescue URI::InvalidURIError => error
      Geomonitor.logger.error "#{error} url is \"#{url}\" for host_id #{host.id}"
      p = false
    end
    Geomonitor.logger.info "Ping result: #{p}"
    current = Ping.create(host_id: host.id, status: p, latest: true)

    old_pings = Ping.where(host_id: host.id).where('id != ?', current.id)

    if old_pings.length > 0
      old_pings.each do |old|
        old.latest = false
        old.save
      end
    end
  end

  def self.recent_status
    last.status if last
  end

  private

    def self.host_url(host)

      # check if host is a princeton iiif server
      if host.url =~ /libimages/i
        "#{host.url}"
      else
        "#{host.url}/wms"
      end
    end
end
