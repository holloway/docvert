# -*- coding: utf-8 -*-
import os
import os.path
import tempfile
import StringIO
import commands
import Image # Python PIL
import pipeline_item
import core.docvert_xml
import core.opendocument
import core.docvert_libreoffice
import lxml.etree

class ConvertImages(pipeline_item.pipeline_stage):
    synonym_formats = dict( #Not just synonyms, but types of files that are converted using the same code (eg, emf=wmf)
        emf='wmf',wmf='wmf',#horrible old vector
        pdf='pdf', ps='pdf', #moderately horrible vector
        svg='svg',#vector
        ani='png',apng='png',art='png',bef='png',bmf='png',bmp='png',cgm='png',cin='png',cpc='png',dpx='png',ecw='png',exr='png',fits='png',flic='png',fpx='png',gif='png',icer='png',ics='png',iff='png',iges='png',ilbm='png',jbig='png',jbig2='png',jng='png',jpe='png',jpg='png',jpeg='png',jp2='png',mng='png',miff='png',pbm='png',pcx='png',pgf='png',pgm='png',png='png',ppm='png',psp='png',raw='png',rad='png',rgbe='png',sgi='png',tga='png',tif='png',tiff='png',webp='png',xar='png',xbm='png',xcf='png',xpm='png' #bitmap
    )
    
    def stage(self, pipeline_value):
        self.intermediate_files = list()
        intermediate_file_extensions_to_retain = list()
        #TODO add format sniffing code
        conversions = dict()
        if not self.storage.has_key('__convertimages'):
            self.storage['__convertimages'] = dict()
        # 1. Parse conversion requests
        formats = ("%s," % self.attributes["formats"]).split(",")
        for format in formats:
            conversion = format.strip(" ._-\n\r").lower()
            if len(conversion) == 0: continue
            from_format, to_format = conversion.split("2")
            if self.synonym_formats.has_key(from_format):
                from_format = self.synonym_formats[from_format]
            if not conversions.has_key(from_format):
                conversions[from_format] = list()
            intermediate_file_extensions_to_retain.append(str(to_format))
            conversions[str(from_format)].append(str(to_format))

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
            for storage_path in storage_paths:
                if not storage_path.startswith(self.pipeline_storage_prefix):
                    continue
                extension = os.path.splitext(storage_path)[1][1:]
                if conversions.has_key(extension):
                    self.storage.remove(storage_path)

        for intermediate_file in self.intermediate_files:
            path, extension = os.path.splitext(intermediate_file)
            extension_minus_dot = str(extension[1:])
            if not extension_minus_dot in intermediate_file_extensions_to_retain:
                try:
                    del self.storage[intermediate_file]
                except KeyError, e:
                    pass

        return pipeline_value

    def convert_wmf(self, storage_path, to_format, pipeline_value, width=None, height=None):
        # We can't reliably parse wmf/emf here so use LibreOffice to generate PDF no matter the to_format
        path, extension = os.path.splitext(storage_path)
        pdf_path = str("%s.pdf" % path)
        if not self.storage.has_key(pdf_path):
            if width is None or height is None:
                width, height, pipeline_value = self.get_dimensions_from_xml(storage_path, pipeline_value, to_format)
            #print "Generate document for %s because %s doesn't exist\n%s\n\n" % (storage_path, pdf_path, self.storage.keys())
            opendocument = core.opendocument.generate_single_image_document(self.storage[storage_path], width, height)
            self.storage[pdf_path] = core.docvert_libreoffice.get_client().convert_by_stream(opendocument, core.docvert_libreoffice.LIBREOFFICE_PDF)
        else:
            #print "Cache hit! No need to generate %s" % pdf_path
            pass
        if to_format == 'pdf':
            return pipeline_value
        self.intermediate_files.append(pdf_path)
        from_format = 'pdf'
        if self.synonym_formats.has_key(from_format):
            from_format = self.synonym_formats[from_format]
        from_format_method = "convert_%s" % from_format
        return getattr(self, from_format_method)(pdf_path, to_format, pipeline_value, width, height)

    def convert_pdf(self, storage_path, to_format, pipeline_value, width=None, height=None):
        path, extension = os.path.splitext(storage_path)
        svg_path = str("%s.svg" % path)
        if not self.storage.has_key(svg_path):
            if width is None or height is None:
                width, height, pipeline_value = self.get_dimensions_from_xml(storage_path, pipeline_value)
            from_format = str(extension[1:])
            synonym_from_format = from_format
            if self.synonym_formats.has_key(synonym_from_format):
                synonym_from_format = self.synonym_formats[synonym_from_format]
            self.storage[svg_path] = self.run_conversion_command_with_temporary_files(storage_path, "pdf2svg %s %s")
        else:
            #print "Cache hit! No need to generate %s" % svg_path
            pass
        if to_format == 'svg':
            return pipeline_value
        self.intermediate_files.append(svg_path)
        from_format = 'svg'
        if self.synonym_formats.has_key(from_format):
            from_format = self.synonym_formats[from_format]
        from_format_method = "convert_%s" % from_format
        return getattr(self, from_format_method)(svg_path, to_format, pipeline_value, width, height)

    def convert_svg(self, storage_path, to_format, pipeline_value, width=None, height=None):
        path, extension = os.path.splitext(storage_path)
        png_path = str("%s.png" % path)
        if not self.storage.has_key(png_path):
            if width is None or height is None:
                width, height, pipeline_value = self.get_dimensions_from_xml(storage_path, pipeline_value)
            from_format = str(extension[1:])
            synonym_from_format = from_format
            if self.synonym_formats.has_key(synonym_from_format):
                synonym_from_format = self.synonym_formats[synonym_from_format]
            self.storage[png_path] = self.run_conversion_command_with_temporary_files(storage_path, "rsvg %s %s")
        else:
            #print "Cache hit! No need to generate %s" % png_path
            pass
        if to_format == 'png':
            return pipeline_value
        self.intermediate_files.append(png_path)
        from_format = 'svg'
        if self.synonym_formats.has_key(from_format):
            from_format = self.synonym_formats[from_format]
        from_format_method = "convert_%s" % from_format
        return getattr(self, from_format_method)(png_path, to_format, pipeline_value, width, height)
        
    def convert_png(self, storage_path, to_format, pipeline_value, width=None, height=None):
        #im = Image.open('icon.gif')
        #transparency = im.info['transparency'] 
        #im .save('icon.png', transparency=transparency)
        #print dir(Image)
        return pipeline_value

    def get_dimensions_from_xml(self, storage_path, pipeline_value, change_image_path_extension_to=None):
        def get_value(data):
            if hasattr(data, 'read'):
                data.seek(0)
                return data.read()
            return data
        path, extension = os.path.splitext(storage_path)
        path = str(path)
        if self.storage['__convertimages'].has_key(path): #intentionally extensionless because all formats of this single image are considered to have the same dimensions
            return (self.storage['__convertimages'][path]['width'], self.storage['__convertimages'][path]['height'], pipeline_value)

        default_dimensions = ('10cm', '10cm') #we had to choose something
        #if self.pipeline_storage_prefix:
        #    storage_path = storage_path[len(self.pipeline_storage_prefix) + 1:]
        xml = self.get_document(pipeline_value)
        namespaces = {'xlink':'http://www.w3.org/1999/xlink'}
        xpath = '//*[@xlink:href="%s"]/parent::*' % storage_path
        image_nodes = xml.xpath(xpath, namespaces=namespaces)
        if len(image_nodes) == 0: #can't do anything, might have been a thumbnail or unlinked image, but either way return 10cm square
            #images = xml.xpath('//*[@xlink:href]', namespaces=namespaces)
            #print "Could not find image node with %s. Document contains: \n%s\n%s. Prefix was %s" % (xpath, images[0], images[0].attrib, self.pipeline_storage_prefix)
            return default_dimensions[0], default_dimensions[1], pipeline_value
        #print "FOUND IMAGE!"
        image_node = image_nodes[0] #first image will be do fine. It's possible to have multiple tags with different width/height pointing at the same image but for now we'll discount that possibility
        oasis_opendocument_svg_namespace = 'urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0'
        width_attribute = "{%s}%s" % (oasis_opendocument_svg_namespace, 'width')
        height_attribute = "{%s}%s" % (oasis_opendocument_svg_namespace, 'height')
        #print "about to read width/height"
        try:
            width = image_node.attrib[width_attribute]
            height = image_node.attrib[height_attribute]
            #print "success... and %s" % change_image_path_extension_to
            if change_image_path_extension_to:
                path, extension = os.path.splitext(storage_path)
                xlink_href_attribute = "{%s}%s" % (namespaces['xlink'], 'href')
                change_image_path = '%s.%s' % (path, change_image_path_extension_to)
                #print "New image path is %s" % change_image_path
                image_nodes = image_node.xpath('*[@xlink:href="%s"]' % storage_path, namespaces=namespaces)
                for image_node in image_nodes:
                    #print "Value was %s" % image_node.attrib[xlink_href_attribute]
                    image_node.attrib[xlink_href_attribute] = change_image_path
                    #print "Value is %s" % image_node.attrib[xlink_href_attribute]
            self.storage['__convertimages'][path] = dict(width=width, height=height) #intentionally extensionless because all formats of this single image are considered to have the same dimensions
            return (width, height, lxml.etree.tostring(xml))
        except KeyError, e:
            pass
        return default_dimensions[0], default_dimensions[1], pipeline_value

    def get_document(self, pipeline_value):
        xml = core.docvert_xml.get_document(pipeline_value)
        if hasattr(xml, "getroottree"):
            xml = xml.getroottree()
        elif hasattr(xml, 'getroot'):
            xml = xml.getroot()
        return xml

    def run_conversion_command_with_temporary_files(self, from_storage_path, command_template):
        def get_value(data):
            if hasattr(data, 'read'):
                data.seek(0)
                return data.read()
            return data
        temporary_from_path = None
        temporary_to_path = None
        try:
            os_handle, temporary_from_path = tempfile.mkstemp()
            temporary_from_file = open(temporary_from_path, 'w')
            temporary_from_file.write(get_value(self.storage[from_storage_path]))
            temporary_from_file.flush()
            temporary_from_file.close()
            os_handle, temporary_to_path = tempfile.mkstemp()
            command = command_template % (temporary_from_path, temporary_to_path)
            std_response = commands.getstatusoutput(command)
            if os.path.getsize(temporary_to_path) == 0:
                raise Exception('Error in convertimages.py: No output data created. Command was "%s" which returned "%s"' % (command_template, std_response))
            temporary_to = open(temporary_to_path, 'r')
            to_data = temporary_to.read()
            temporary_to.close()
            return to_data
        finally:
            if temporary_from_path: os.remove(temporary_from_path)
            if temporary_to_path: os.remove(temporary_to_path)


"""
#NOTE: Poppler doesn't work on my [Matthew Holloway's] Ubuntu 10.10 machine. It seg faults so that's why I'm shelling out
#import cairo
#import poppler
os_handle, temporary_file_path = tempfile.mkstemp()
temporary_file = open(temporary_file_path, 'w')
temporary_file.write(get_value(self.storage[storage_path]))
temporary_file.flush()
print temporary_file_path
pdf = poppler.document_new_from_file(
    "file://%s" % temporary_file_path,
    password=None)
first_page = pdf.get_page(0)
surface = cairo.PDFSurface(surface_storage, width_float, height_float)
cairo_context = cairo.Context(surface)

first_page.render(cairo_context)
surface.write_to_png("/tmp/page0.png")
print dir(first_page)
temporary_file.close()
"""

