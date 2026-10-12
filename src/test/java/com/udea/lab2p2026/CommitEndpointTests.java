package com.udea.lab2p2026;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest(properties = "app.commit=abc123")
class CommitEndpointTests {
	@Autowired
	DataController dataController;

	@Test
	void commitReturnsConfiguredValue() {
		assertEquals("abc123", dataController.commit());
	}
}
