# -*- coding: utf-8 -*-
import cgi
import os
import zipfile
import lxml.etree
import StringIO
import pipeline_item
import core.docvert_exception

class SerializeOpenDocument(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        storage_path = "%s/%s" % (self.pipeline_storage_prefix, self.attributes['toFile'])
        if self.pipeline_storage_prefix is None:
            storage_path = self.attributes['toFile']
        if '{customSection}' in storage_path:
            depth_string = 'section'
            depth_string += "-".join(self.depth)
            depth_string += ".odt"
            storage_path = storage_path.replace('{customSection}', depth_string) 
        if not isinstance(pipeline_value, lxml.etree._Element) and not isinstance(pipeline_value, lxml.etree._XSLTResultTree):
            return pipeline_value
        zipdata = StringIO.StringIO()
        archive = zipfile.ZipFile(zipdata, 'w')
        archive.writestr('mimetype', 'application/vnd.oasis.opendocument.text')
        manifest_xml = '<?xml version="1.0" encoding="UTF-8"?>\n<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">\n\t<manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.text" manifest:version="1.2" manifest:full-path="/"/>\n'
        root = pipeline_value.getroot()
        expected_lxml_root = '{docvert:5}root'
        if str(root.tag) != expected_lxml_root:
            raise core.docvert_exception.unable_to_serialize_opendocument("Can't serialize OpenDocument with a pipeline_value root node of '%s'." % root.tag)
        expected_lxml_child = '{docvert:5}external-file'
        for child in root.iterchildren():
            if str(child.tag) != expected_lxml_child:
                raise core.docvert_exception.unable_to_serialize_opendocument("Can't serialize OpenDocument with a pipeline_value child node of '%s'." % child.tag)
            filename = str(child.attrib['{docvert:5}name'])
            xml = "".join(map(lxml.etree.tostring, child.getchildren()))
            print "{%s]" % filename
            archive.writestr(filename, xml)
            manifest_xml += '\t<manifest:file-entry manifest:media-type="%s" manifest:full-path="%s"/>\n' % (cgi.escape('text/xml'), cgi.escape(filename))
        manifest_xml += '\t<manifest:file-entry media-type="" manifest:full-path="Pictures/"/>\n'
        imagetypes = {".svg":"image/svg+xml", ".png":"image/png", ".gif":"image/gif", ".bmp":"image/x-ms-bmp", ".jpg":"image/jpeg", ".jpe":"image/jpeg", ".jpeg":"image/jpeg"}
        for storage_key in self.storage.keys():
            if storage_key.startswith(self.pipeline_storage_prefix):
                extension = os.path.splitext(storage_key)[1]
                if extension in imagetypes.keys():
                    odt_path = "Pictures/%s" % os.path.basename(storage_key)
                    manifest_xml += '\t<manifest:file-entry media-type="%s" manifest:full-path="%s"/>\n' % (cgi.escape(imagetypes[extension]), cgi.escape(odt_path) )
                    archive.writestr(odt_path, self.storage[storage_key])
        manifest_xml += '</manifest:manifest>'
        archive.writestr('META-INF/manifest.xml', manifest_xml.encode("utf-8") )
        archive.close()
        zipdata.seek(0)
        self.storage.add(storage_path, zipdata.read())



