-- Configuration for MathML-to-SVG formatter.
sax.ContentHandler-- Configuration for MathML-to-SVG formatter.
    
    Implements SAX ContentHandler for ease of reading from file.

__init__ = function(self, configfile)
  self.verbose = false
  self.debug = {}
  self.currentFamily = nil
  self.fonts = { }
  self.variants = { }
  self.defaults = { }
  self.opstyles = { }
  self.fallbackFamilies = {}
  parser = sax.make_parser()
  parser.setContentHandler(self)
  parser.setFeature(sax.handler.feature_namespaces, 0)
  parser.parse(configfile)
sax.SAXExceptionxcptprint('Error parsing configuration file 'configfile': 'xcpt.getMessage())  sys.exit(1)
end

startElement = function(self, name, attributes)
  if name=='config' then
    self.verbose = attributes.get('verbose')=='true'
    self.debug = attributes.get('debug', '').replace(',', ' ').split()
  elseif name=='defaults' then
    self.defaults.update(attributes)
  elseif name=='fallback' then
    familyattr = attributes.get('family', '')
    self.fallbackFamilies = pylua.COMPREHENSION()
  elseif name=='family' then
    self.currentFamily = attributes.get('name', '')
    self.currentFamily = pylua.str_maybe('').join(self.currentFamily.lower().split())
  elseif name=='font' then
    weight = attributes.get('weight', 'normal')
    style = attributes.get('style', 'normal')
    fontfullname = self.currentFamily
    if weight~='normal' then
      fontfullname = fontfullname+' '+weight
    end
    if style~='normal' then
      fontfullname = fontfullname+' '+style
    end
    if pylua.op_in('afm', attributes.keys()) then
      fontpath = attributes.get('afm')
      metric = AFMMetric(fontpath, attributes.get('glyph-list'), sys.stderr)
    elseif pylua.op_in('ttf', attributes.keys()) then
      fontpath = attributes.get('ttf')
      metric = TTFMetric(fontpath, sys.stderr)
    else
      sys.stderr.write('Bad record in configuration file: font is neither AFM nor TTF\n')
      sys.stderr.write(pylua.mod('Font entry for \'%s\' ignored\n', fontfullname))
      return 
    end
FontFormatErrorerr    sys.stderr.write(pylua.mod('Invalid or unsupported file format in \'%s\': %s\n', fontpath, err.message))
    sys.stderr.write(pylua.mod('Font entry for \'%s\' ignored\n', fontfullname))
    return 
IOError    message = sys.exc_info()[2]
    sys.stderr.write(pylua.mod('I/O error reading font file \'%s\': %s\n', fontpath, str(message)))
    sys.stderr.write(pylua.mod('Font entry for \'%s\' ignored\n', fontfullname))
    return 
    self.fonts[weight+' '+style+' '+self.currentFamily] = metric
  elseif name=='mathvariant' then
    variantattr = attributes.get('name')
    familyattr = attributes.get('family', '')
    splitFamily = pylua.COMPREHENSION()
    weightattr = attributes.get('weight', 'normal')
    styleattr = attributes.get('style', 'normal')
    self.variants[variantattr] = weightattr, styleattr, splitFamily
  elseif name=='operator-style' then
    opname = attributes.get('operator')
    if opname then
      styling = { }
      styling.update(attributes)
styling['operator']      self.opstyles[opname] = styling
    else
      sys.stderr.write('Bad record in configuration file: operator-style with no operator attribute\n')
    end
  end
end

endElement = function(self, name)
  if name=='family' then
    self.currentFamily = nil
  end
end

findfont = function(self, weight, style, family)
  -- Finds a metric for family+weight+style.
  weight = weight or 'normal'.strip()
  style = style or 'normal'.strip()
  family = pylua.str_maybe('').join(family or ''.lower().split())
  for w in ipairs({weight, 'normal'}) do
    for s in ipairs({style, 'normal'}) do
      metric = self.fonts.get(w+' '+s+' '+family)
      if metric then
        return metric
      end
    end
  end
  return nil
end

main = function()
  if len(sys.argv)==1 then
    config = MathConfig(nil)
  else
    config = MathConfig(sys.argv[2])
  end
print('Options:  verbose ='config.verbose' debug ='config.debug)print('Fonts:')  for font, metric in ipairs(config.fonts.items()) do
print('    'font'-->'metric.fontname)  end
print('Math variants:')  for variant, value in ipairs(config.variants.items()) do
print('    'variant'-->'value)  end
print('Defaults:')  for attr, value in ipairs(config.defaults.items()) do
print('    'attr'='value)  end
print('Operator styling:')  for opname, value in ipairs(config.opstyles.items()) do
print('    'repr(opname)':'value)  end
print('Fallback font families:'config.fallbackFamilies)end
if __name__=='__main__' then
  main()
end
