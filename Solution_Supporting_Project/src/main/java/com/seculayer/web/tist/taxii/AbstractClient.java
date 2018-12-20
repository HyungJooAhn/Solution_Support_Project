package com.seculayer.web.tist.taxii;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

import javax.xml.bind.JAXBException;

import org.apache.commons.cli.CommandLine;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.AuthCache;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLContextBuilder;
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.impl.client.BasicAuthCache;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.log4j.Logger;
import org.mitre.taxii.client.HttpClient;
import org.mitre.taxii.messages.TaxiiXml;
import org.mitre.taxii.messages.xml11.ObjectFactory;
import org.mitre.taxii.messages.xml11.TaxiiXmlFactory;

/**
 * Provides a set of common command line handling methods and other things
 * common across all the example client apps.
 * 
 * @author jasenj1
 */
abstract class AbstractClient {
    final Cli cli;    
    ObjectFactory factory = new ObjectFactory();
    TaxiiXmlFactory txf = new TaxiiXmlFactory();
    TaxiiXml taxiiXml;
    HttpClient taxiiClient;

    Logger logger = Logger.getLogger(AbstractClient.class);
    
    protected HttpClientContext context;

    AbstractClient() {
    	this.cli = new Cli();
    	taxiiXml = txf.createTaxiiXml();
    }
    
    public Cli getCli() {
        return cli;
    }
    
    /**
     * Generate a properly configured HttpClient based on the options in the 
     * command line.
     * (The class holds an instance of an object holding the command line, but 
     * I want it to be clear where the configuration information is coming from
     * so it gets passed in.)
     * 
     * @param cmd
     * @return 
     */
    HttpClient generateClient(CommandLine cmd) throws MalformedURLException, Exception {
      
		HttpClient client = new HttpClient();
        // Create an Apache HttpClientBuilder to be customized by the command line arguments.
        HttpClientBuilder builder = HttpClientBuilder.create().useSystemProperties();
        // Proxy
        if (cmd.hasOption("proxy")) {
            try {
            URL proxyURL = new URL(cmd.getOptionValue("proxy"));
            HttpHost proxyHost = new HttpHost(proxyURL.getHost(), proxyURL.getPort(), proxyURL.getProtocol());
            builder.setProxy(proxyHost);
            } catch (MalformedURLException ex) {
                throw new MalformedURLException("Malformed proxy URL");
            }
        }
        
        // Basic authentication. User & Password
        if (cmd.hasOption("username") ^ cmd.hasOption("password")) {
            throw new Exception("'username' and 'password' arguments are required to appear together.");
        }
        
        URL targetURL = new URL(cmd.getOptionValue("u"));
        HttpHost target = new HttpHost(targetURL.getHost(), 443, targetURL.getProtocol());
        
        if (cmd.hasOption("username") && cmd.hasOption("password")) {

            CredentialsProvider credsProvider = new BasicCredentialsProvider();
            credsProvider.setCredentials(
            		new AuthScope(target.getHostName(), target.getPort()),
                    new UsernamePasswordCredentials(cmd.getOptionValue("username"), cmd.getOptionValue("password")));   
            
            AuthCache authCache = new BasicAuthCache();
            authCache.put(target, new BasicScheme());
             
            context = HttpClientContext.create();
            context.setCredentialsProvider(credsProvider);
            context.setAuthCache(authCache);
        } else {
            context = null;
        }
        SSLContextBuilder ssbldr = new SSLContextBuilder();
        ssbldr.loadTrustMaterial(null, new TrustSelfSignedStrategy());
        SSLConnectionSocketFactory sslsf = new SSLConnectionSocketFactory(ssbldr.build(),SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);


        Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory>create()
                .register("http", new PlainConnectionSocketFactory())
                .register("https", sslsf)
                .build();


        PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager(registry);
        cm.setMaxTotal(20);//max connection

        System.setProperty("jsse.enableSNIExtension", "false"); //""
        CloseableHttpClient httpClient = builder
                .setSSLSocketFactory(sslsf)
                .setConnectionManager(cm)
                .build();
                        
        client.setHttpclient(httpClient);
        return client;
    }    
    
    public Object doCall(Object request, String url) throws JAXBException, IOException, URISyntaxException {
        Object responseObj = taxiiClient.callTaxiiService(new URI(url), request, context);

        return responseObj;
    }
}