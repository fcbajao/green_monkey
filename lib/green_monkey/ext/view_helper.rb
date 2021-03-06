# coding: utf-8

require "chronic_duration"
module GreenMonkey
  module ViewHelper

    # it shortcut for this
    # %time{:datetime => post.published_at.iso8601(10) }= post.published_at.strftime("%d %h %Y")

    # = time_tag post.created_at
    # = time_tag post.created_at, format: "%d %h %Y %R%p"
    # = time_tag post.created_at, itemprop: "datePublished"
    def time_tag(time, *args)
      options  = args.extract_options!
      format   = options.delete(:format) || :long
      datetime = time_to_iso8601(time)


      if time.acts_like?(:time)
        title = nil
        content  = args.first || I18n.l(time, format: format)
      elsif time.kind_of?(Numeric)
        title = ChronicDuration.output(time, :format => format)
        content = args.first || distance_of_time_in_words(time)
      else
        content = time.to_s
      end
      content_tag(:time, content, options.reverse_merge(datetime: datetime, title: title))
    end

    # as second argumnts can get as Time/DateTime object as duration in seconds
    def time_tag_interval(from, to, *args)
      options  = args.extract_options!
      format   = options.delete(:format) || :long

      datetime = [from, to].map(&method(:time_to_iso8601)).join("/")
      content  = args.first || [from, to].map do |time|
        if time.acts_like?(:time)
          I18n.l(from, format: format)
        else
          ChronicDuration.output(time, :format => format)
        end
      end

      if to.acts_like?(:time)
        content = content.join(" - ")
      else
        content = content.join(" in ")
      end

      content_tag(:time, content, options.reverse_merge(datetime: datetime))
    end

    def time_to_iso8601(time)
      if time.acts_like?(:time)
        time.iso8601
      elsif time.kind_of?(Numeric)
        ChronicDuration.output(time, :format => :iso8601)
      end
    end

    def mida_scope(object)
      options = {itemscope: true}
      if object.respond_to?(:html_schema_type)
        if object.html_schema_type.kind_of?(Mida::Vocabulary)
          options.merge! itemtype: object.html_schema_type.itemtype.source
        else
          raise "No vocabulary found (#{obj.html_schema_type})" unless Mida::Vocabulary.find(obj.html_schema_type)
          options.merge! itemtype: object.html_schema_type
        end
      elsif object.is_a?(Symbol)
        options.merge! itemtype: Mida(object)
      elsif object.is_a?(String)
        options.merge! itemtype: object
      end

      tag_options(options)
    end

    def breadcrumb_link_to(title, path, options = {})
      content_tag(:span, itemscope: true, itemtype: 'http://data-vocabulary.org/Breadcrumb') do
        link_to(content_tag(:span, title, itemprop: 'title'), path, options.merge(itemprop: 'url')) + ''
      end
    end
  end
end