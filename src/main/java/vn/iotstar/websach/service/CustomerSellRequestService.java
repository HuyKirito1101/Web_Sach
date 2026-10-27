package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.SellRequestSubmission;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.SellRequest;
import vn.iotstar.websach.entity.SellRequestQuote;
import vn.iotstar.websach.entity.User;

import java.util.List;

public interface CustomerSellRequestService {
    List<Branch> getActiveBranches();
    User getCustomer(String email);
    List<SellRequest> getCustomerRequests(String email);
    SellRequest submitRequest(String email, SellRequestSubmission submission);
    SellRequestQuote acceptQuote(String email, Long requestId, Long quoteId);
    SellRequest acceptOffer(String email, Long requestId);
    SellRequest cancelRequest(String email, Long requestId);
}
