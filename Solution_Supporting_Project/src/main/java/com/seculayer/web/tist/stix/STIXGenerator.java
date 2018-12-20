package com.seculayer.web.tist.stix;

/**
 * Copyright (c) 2015, The MITRE Corporation. All rights reserved.
 * See LICENSE for complete terms.
 */

import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.Map;
import java.util.TimeZone;
import java.util.UUID;

import javax.xml.bind.JAXBException;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.namespace.QName;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.lang.StringUtils;
import org.mitre.stix.common_1.IndicatorBaseType;
import org.mitre.stix.common_1.StructuredTextType;
import org.mitre.stix.indicator_2.Indicator;
import org.mitre.stix.stix_1.IndicatorsType;
import org.mitre.stix.stix_1.STIXHeaderType;
import org.mitre.stix.stix_1.STIXPackage;
import org.xml.sax.SAXException;

public class STIXGenerator {

	public STIXGenerator() {}

	/**
	 * @param args
	 * @throws DatatypeConfigurationException
	 * @throws JAXBException
	 * @throws ParserConfigurationException
	 */

	public String generate(Map<String, Object> map) throws SAXException {
		String result = "";
		try {
			// Get time for now.
			XMLGregorianCalendar now = DatatypeFactory.newInstance()
					.newXMLGregorianCalendar(
							new GregorianCalendar(TimeZone.getTimeZone("UTC")));
			final Indicator indicator = new Indicator()
					.withId(new QName(map.get("indicator_namespace").toString(), "indicator-"
							+ UUID.randomUUID().toString(), map.get("indicator_prefix").toString()))
					.withTimestamp(now)
					.withTitle(map.get("indicator_title").toString())
					.withDescriptions(
							new StructuredTextType()
									.withValue(map.get("indicator_description").toString()));
				//	.withProducer(producer).withObservable(observable);
			IndicatorsType indicators = new IndicatorsType(
					new ArrayList<IndicatorBaseType>() {
						{
							add(indicator);
						}
					});
			STIXHeaderType header = new STIXHeaderType()
					.withDescriptions(new StructuredTextType()
							.withValue(map.get("header_description").toString()));
			STIXPackage stixPackage = new STIXPackage()
					.withSTIXHeader(header)
					.withIndicators(indicators)
					.withVersion("1.2")
					.withTimestamp(now)
					.withId(new QName(map.get("header_namespace").toString(), "package-"
							+ UUID.randomUUID().toString(), map.get("header_prefix").toString()));
			result = stixPackage.toXMLString(true);
		} catch (DatatypeConfigurationException e) {
			throw new RuntimeException(e);
		} 
		return result;
	}
}