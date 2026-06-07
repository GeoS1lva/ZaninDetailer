from datetime import datetime
from decimal import Decimal
from enum import Enum

from sqlalchemy import (
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.infra.database import Base


class AppointmentStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"
    COMPLETED = "completed"


class Appointment(Base):
    __tablename__ = "appointments"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)

    client_id: Mapped[int] = mapped_column(ForeignKey("clients.id"), nullable=False, index=True)
    service_id: Mapped[int] = mapped_column(ForeignKey("services.id"), nullable=False, index=True)

    scheduled_start: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    scheduled_end: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default=AppointmentStatus.PENDING,
        index=True,
    )
    total_price: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)

    google_event_id: Mapped[str | None] = mapped_column(String(200), nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    client: Mapped["Client"] = relationship(back_populates="appointments")
    service: Mapped["Service"] = relationship()
    history: Mapped[list["AppointmentHistory"]] = relationship(
        back_populates="appointment", order_by="AppointmentHistory.changed_at"
    )

    def __repr__(self) -> str:
        return (
            f"<Appointment id={self.id} status={self.status} "
            f"start={self.scheduled_start} client_id={self.client_id}>"
        )


class AppointmentHistory(Base):
    __tablename__ = "appointment_history"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    appointment_id: Mapped[int] = mapped_column(
        ForeignKey("appointments.id"), nullable=False, index=True
    )

    previous_status: Mapped[str | None] = mapped_column(String(20), nullable=True)
    new_status: Mapped[str | None] = mapped_column(String(20), nullable=True)
    previous_start: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    new_start: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    changed_by: Mapped[str] = mapped_column(String(50), nullable=False)
    changed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    appointment: Mapped["Appointment"] = relationship(back_populates="history")