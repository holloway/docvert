# -*- coding: utf-8 -*-
import os.path
import pipeline_item
import core.docvert_xml
import core.opendocument
import core.docvert_libreoffice

class ConvertImages(pipeline_item.pipeline_stage):
    synonym_formats = dict( #Not just synonyms, but types of files that are converted using the same code (eg, emf=wmf)
        emf='wmf',
        jpe='jpeg',
        jpg='jpeg'
    )
    libreoffice_client = None

    def stage(self, pipeline_value):
        conversions = dict()

        # 1. Parse conversion requests
        formats = ("%s," % self.attributes["formats"]).split(",")
        for format in formats:
            format = format.strip(" ._-\n\r")
            if len(format) == 0: continue
            from_format, to_format = format.split("2")
            if from_format in self.synonym_formats.keys():
                from_format = self.synonym_formats[from_format]
            if not conversions.has_key(from_format):
                conversions[from_format] = list()
            conversions[str(from_format)].append(str(to_format)) #ensure str

        # 2. Convert images
        # <stage process="ConvertImages" formats="wmf2png, wmf2svg, bmp2png" deleteOriginals="true" autoCrop="false" autoCropThreshold="20"/>
        storage_paths = self.storage.keys()
        for storage_path in storage_paths:
            if self.pipeline_storage_prefix and not storage_path.startswith(self.pipeline_storage_prefix):
                continue
            path, extension = os.path.splitext(storage_path)
            extension_minus_dot = str(extension[1:])
            for from_format, to_formats in conversions.iteritems():
                from_format_method = "convert_%s" % extension_minus_dot
                if extension_minus_dot == from_format and hasattr(self, from_format_method):
                    for to_format in to_formats:
                        pipeline_value = getattr(self, from_format_method)(storage_path, to_format, pipeline_value)

        # 3. Delete original images
        if self.attributes.has_key("deleteOriginals") and not self.attributes["deleteOriginals"].strip().lower() in ['false','f','n','0','']:
            for storage_file in storage_files:
                if not storage_file.startswith(self.pipeline_storage_prefix):
                    continue
                extension = os.path.splitext(storage_file)[1][1:]
                if extension in conversions.keys():
                    self.storage.remove(storage_file)
        #done
        return pipeline_value

    def convert_wmf(self, storage_path, to_format, pipeline_value):
        # 1. We can't parse wmf/emf reliably here so use LibreOffice to generate PDF
        xml = core.docvert_xml.get_document(pipeline_value)
        if hasattr(xml, "getroottree"):
            xml = xml.getroottree()
        elif hasattr(xml, 'getroot'):
            xml = xml.getroot()
        image_nodes = xml.xpath('//*[@xlink:href="%s"]/parent::*' % storage_path, namespaces={'xlink':'http://www.w3.org/1999/xlink'})
        if len(image_nodes) == 0: #can't do anything, might have been a thumbnail or unlinked image
            return pipeline_value
        image_node = image_nodes[0] #first image will be do fine. It's possible to have multiple tags with different width/height pointing at the same image but for now we'll discount that possibility
        oasis_opendocument_svg_namespace = 'urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0'
        width_key = "{%s}%s" % (oasis_opendocument_svg_namespace, 'width')
        height_key = "{%s}%s" % (oasis_opendocument_svg_namespace, 'height')
        try:
            width = image_node.attrib[width_key]
            height = image_node.attrib[height_key]
        except KeyError, e:
            return pipeline_value
        opendocument = core.opendocument.generate_single_image_document(self.storage[storage_path], width, height)
        pdf = core.docvert_libreoffice.client.convert_by_stream(opendocument, core.docvert_libreoffice.LIBREOFFICE_PDF)
        path, extension = os.path.splitext(storage_path)
        self.storage["%s.pdf" % path] = pdf
        return pipeline_value


