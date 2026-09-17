package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Publisher;

@Repository
public interface PublisherRepository extends JpaRepository<Publisher, Long> {
}
