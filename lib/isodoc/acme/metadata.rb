require "isodoc"

module IsoDoc
  module Acme

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        default_logo_path = File.expand_path(File.join(here, "html", "logo.jpg"))
        set(:logo, Metanorma::Acme.configuration.logo_path || default_logo_path)
      end

      def author(isoxml, _out)
        super
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def docid(isoxml, _out)
        docnumber = isoxml.at(ns("//bibdata/docidentifier"))
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        dn = docnumber&.text
        if docstatus
          abbr = status_abbr(docstatus.text)
          dn = "#{dn}(#{abbr})" unless abbr.empty?
        end
        set(:docnumber, dn)
      end

      def status_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def unpublished(status)
        !%w(published withdrawn).include? status.downcase
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_monthyear, monthyr(revdate))
      end

      MONTHS = {
        "01": "January",
        "02": "February",
        "03": "March",
        "04": "April",
        "05": "May",
        "06": "June",
        "07": "July",
        "08": "August",
        "09": "September",
        "10": "October",
        "11": "November",
        "12": "December",
      }.freeze

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]
        return "#{MONTHS[m[:mo].to_sym]} #{m[:yr]}"
      end

      def security(isoxml, _out)
        security = isoxml.at(ns("//bibdata/ext/security")) || return
        set(:security, security.text)
      end
    end
  end
end
