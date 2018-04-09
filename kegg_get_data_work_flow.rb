require 'nokogiri'
require 'open-uri'

def set_nokogiri(url)
	charset = nil
	html = open(url) do |f|
	    charset = f.charset
	    f.read
	end
	Nokogiri::HTML.parse(html, nil, charset)
end

def get_gene_urls(url)
	arr = []
	set_nokogiri(url).css('a').each do |anchor|
		arr << anchor[:href] unless anchor[:href] == nil
	end
	arr.select! { |e| e.include?('/dbget-bin/www_bget?') }
end


def get_org_id
	@doc.xpath('//td/div/a').text.slice(/[a-z]+/)
end

def get_data_basic(st,condition)
	x = "unknown"
	for i in 1..20
		left_th = @doc.xpath("//tr[#{i}]/th")
		if left_th.text == st
			eval condition
			break
		end
	end
	return x
end

def get_entry
	get_data_basic("Entry", 'x = @doc.xpath("//td[1]/code/nobr/text()")').to_s.split(" ")[0].to_s
end

def get_org_name
	get_data_basic("Organism", 'x = @doc.xpath("//tr[#{i}]/td/div/text()")').to_s.delete("  ").delete("\n")
end

def get_position
	get_data_basic("Position", 'x = @doc.xpath("//tr[#{i}]/td/div/text()")').to_s.delete("\n")
end

def get_aa_seq
	get_data_basic("AA seq", 'x = @doc.xpath("//tr[#{i}]/td/text()").text.split("\n")[1..-1].join')
end

def get_nt_seq
	get_data_basic("NT seq", 'x = @doc.xpath("//tr[#{i}]/td/text()").text.split("\n")[1..-1].join')
end



kegg_orthology_url = 'http://www.genome.jp/dbget-bin/www_bget?ko:K02628' #pecA
gene_urls = get_gene_urls(kegg_orthology_url)

gene_urls.each do |url|
	@doc = set_nokogiri("http://www.genome.jp#{url}")
	name = "#{get_org_id}_#{get_entry}"
	want_data = get_aa_seq

	puts ">#{name}\n#{want_data}\n\n"
end